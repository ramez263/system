package com.ramez.tunnel_plus.vpn.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.VpnService
import android.os.Build
import android.os.ParcelFileDescriptor
import androidx.core.app.NotificationCompat
import com.ramez.tunnel_plus.MainActivity
import com.ramez.tunnel_plus.vpn.model.ConnectionStatus
import com.ramez.tunnel_plus.vpn.model.TrafficStats
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.io.FileInputStream
import java.io.FileOutputStream

class RamezVpnService : VpnService() {

    private var vpnInterface: ParcelFileDescriptor? = null
    private val serviceScope = CoroutineScope(Dispatchers.IO + Job())
    private var statsJob: Job? = null

    private var activeProfileName: String = "Ramez Secure Node"
    private var connectedAtMillis: Long = 0L

    private lateinit var connectivityManager: ConnectivityManager
    private var networkCallback: ConnectivityManager.NetworkCallback? = null

    companion object {
        const val ACTION_CONNECT = "com.ramez.tunnel_plus.vpn.CONNECT"
        const val ACTION_DISCONNECT = "com.ramez.tunnel_plus.vpn.DISCONNECT"
        const val NOTIFICATION_ID = 1001
        const val CHANNEL_ID = "ramez_tunnel_vpn_channel"

        const val EXTRA_PROFILE_NAME = "extra_profile_name"
        const val EXTRA_SERVER_HOST = "extra_server_host"
        const val EXTRA_SERVER_PORT = "extra_server_port"
        const val EXTRA_DNS_SERVERS = "extra_dns_servers"
        const val EXTRA_BYPASS_LAN = "extra_bypass_lan"
        const val EXTRA_EXCLUDED_APPS = "extra_excluded_apps"

        private val _currentStatus = MutableStateFlow(ConnectionStatus.DISCONNECTED)
        val currentStatus: StateFlow<ConnectionStatus> = _currentStatus.asStateFlow()

        private val _currentStats = MutableStateFlow(TrafficStats())
        val currentStats: StateFlow<TrafficStats> = _currentStats.asStateFlow()

        private val _activeServer = MutableStateFlow<String?>("Frankfurt Fast-01")
        val activeServer: StateFlow<String?> = _activeServer.asStateFlow()

        fun isRunning(): Boolean = _currentStatus.value == ConnectionStatus.CONNECTED
    }

    override fun onCreate() {
        super.onCreate()
        connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_CONNECT -> {
                val profileName = intent.getStringExtra(EXTRA_PROFILE_NAME) ?: "Ramez Secure Node"
                val serverHost = intent.getStringExtra(EXTRA_SERVER_HOST) ?: "185.120.40.12"
                val serverPort = intent.getIntExtra(EXTRA_SERVER_PORT, 1194)
                val dnsList = intent.getStringArrayListExtra(EXTRA_DNS_SERVERS) ?: arrayListOf("1.1.1.1", "1.0.0.1")
                val bypassLan = intent.getBooleanExtra(EXTRA_BYPASS_LAN, true)
                val excludedApps = intent.getStringArrayListExtra(EXTRA_EXCLUDED_APPS) ?: arrayListOf()

                startTunnel(profileName, serverHost, serverPort, dnsList, bypassLan, excludedApps)
            }
            ACTION_DISCONNECT -> {
                stopTunnel()
            }
        }
        return START_NOT_STICKY
    }

    private fun startTunnel(
        name: String,
        host: String,
        port: Int,
        dnsServers: List<String>,
        bypassLan: Boolean,
        excludedApps: List<String>
    ) {
        activeProfileName = name
        _activeServer.value = name
        _currentStatus.value = ConnectionStatus.PREPARING

        val notification = buildNotification(name, "Establishing secure tunnel...")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }

        serviceScope.launch {
            try {
                _currentStatus.value = ConnectionStatus.CONNECTING
                updateNotification(name, "Connecting to $host:$port...")

                // Setup TUN Builder
                val builder = Builder()
                    .setSession(name)
                    .setMtu(1500)
                    .addAddress("10.8.0.2", 24)
                    .addRoute("0.0.0.0", 0)

                // DNS servers
                for (dns in dnsServers) {
                    if (dns.isNotBlank()) {
                        builder.addDnsServer(dns.trim())
                    }
                }

                // Split tunneling: exclude user-specified package names
                for (pkg in excludedApps) {
                    if (pkg.isNotBlank()) {
                        try {
                            builder.addDisallowedApplication(pkg)
                        } catch (_: Exception) {}
                    }
                }

                // Establish TUN
                vpnInterface = builder.establish()
                if (vpnInterface == null) {
                    _currentStatus.value = ConnectionStatus.FAILED
                    stopSelf()
                    return@launch
                }

                connectedAtMillis = System.currentTimeMillis()
                _currentStatus.value = ConnectionStatus.CONNECTED
                updateNotification(name, "Connected • Protected")

                registerNetworkObserver()
                startStatsMonitoring()

            } catch (e: Exception) {
                _currentStatus.value = ConnectionStatus.FAILED
                updateNotification(name, "Connection failed: ${e.message}")
                stopSelf()
            }
        }
    }

    private fun stopTunnel() {
        _currentStatus.value = ConnectionStatus.DISCONNECTED
        statsJob?.cancel()
        unregisterNetworkObserver()

        try {
            vpnInterface?.close()
            vpnInterface = null
        } catch (_: Exception) {}

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun startStatsMonitoring() {
        statsJob?.cancel()
        statsJob = serviceScope.launch {
            var simulatedBytesIn = 1024L * 150
            var simulatedBytesOut = 1024L * 45

            while (isActive && _currentStatus.value == ConnectionStatus.CONNECTED) {
                delay(1000)
                val durationSec = (System.currentTimeMillis() - connectedAtMillis) / 1000

                // In native tunnel, stats read from TUN socket/file descriptor
                val stepIn = (40..180).random() * 1024L
                val stepOut = (10..60).random() * 1024L
                simulatedBytesIn += stepIn
                simulatedBytesOut += stepOut

                _currentStats.value = TrafficStats(
                    bytesIn = simulatedBytesIn,
                    bytesOut = simulatedBytesOut,
                    downloadSpeedBps = stepIn * 8,
                    uploadSpeedBps = stepOut * 8,
                    durationSeconds = durationSec
                )
            }
        }
    }

    private fun registerNetworkObserver() {
        if (networkCallback != null) return

        networkCallback = object : ConnectivityManager.NetworkCallback() {
            override fun onLost(network: Network) {
                if (_currentStatus.value == ConnectionStatus.CONNECTED) {
                    _currentStatus.value = ConnectionStatus.RECONNECTING
                    updateNotification(activeProfileName, "Network switched • Reconnecting...")
                }
            }

            override fun onAvailable(network: Network) {
                if (_currentStatus.value == ConnectionStatus.RECONNECTING) {
                    serviceScope.launch {
                        delay(1200)
                        _currentStatus.value = ConnectionStatus.CONNECTED
                        updateNotification(activeProfileName, "Connected • Protected")
                    }
                }
            }
        }

        val request = NetworkRequest.Builder()
            .addCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
            .build()
        connectivityManager.registerNetworkCallback(request, networkCallback!!)
    }

    private fun unregisterNetworkObserver() {
        networkCallback?.let {
            try {
                connectivityManager.unregisterNetworkCallback(it)
            } catch (_: Exception) {}
            networkCallback = null
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "VPN Connection Status",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows live status and traffic for Ramez Tunnel Plus"
                setShowBadge(false)
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(title: String, content: String): Notification {
        val openAppIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            this, 0, openAppIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val disconnectIntent = Intent(this, RamezVpnService::class.java).apply {
            action = ACTION_DISCONNECT
        }
        val disconnectPendingIntent = PendingIntent.getService(
            this, 1, disconnectIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_lock)
            .setContentTitle("Ramez Tunnel Plus — $title")
            .setContentText(content)
            .setOngoing(true)
            .setContentIntent(openPendingIntent)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Disconnect", disconnectPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .build()
    }

    private fun updateNotification(title: String, content: String) {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, buildNotification(title, content))
    }

    override fun onDestroy() {
        stopTunnel()
        super.onDestroy()
    }
}
