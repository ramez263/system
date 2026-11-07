package com.ramez.tunnel_plus.vpn.bridge

import android.app.Activity
import android.content.Context
import android.net.VpnService
import com.ramez.tunnel_plus.vpn.engine.VpnEngineFactory
import com.ramez.tunnel_plus.vpn.service.RamezVpnService
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

class VpnBridgeHandler(
    private val context: Context,
    private var activity: Activity?,
    messenger: BinaryMessenger
) : VpnHostApi {

    private val engineFactory = VpnEngineFactory(context)
    private val scope = CoroutineScope(Dispatchers.Main + Job())

    private var statusEventSink: EventChannel.EventSink? = null
    private var statsEventSink: EventChannel.EventSink? = null

    companion object {
        const val STATUS_CHANNEL = "com.ramez.tunnel_plus/vpn_status"
        const val STATS_CHANNEL = "com.ramez.tunnel_plus/vpn_stats"
        const val VPN_PREPARE_REQUEST_CODE = 9001

        var pendingPrepareCallback: ((Result<Boolean>) -> Unit)? = null
    }

    init {
        VpnHostApi.setUp(messenger, this)

        // Status EventChannel
        EventChannel(messenger, STATUS_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                statusEventSink = events
                events?.success(RamezVpnService.currentStatus.value.value)
            }

            override fun onCancel(arguments: Any?) {
                statusEventSink = null
            }
        })

        // Stats EventChannel
        EventChannel(messenger, STATS_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                statsEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                statsEventSink = null
            }
        })

        // Collect StateFlows and emit to Flutter
        scope.launch {
            RamezVpnService.currentStatus.collectLatest { status ->
                statusEventSink?.success(status.value)
            }
        }

        scope.launch {
            RamezVpnService.currentStats.collectLatest { stats ->
                val map = mapOf(
                    "bytesIn" to stats.bytesIn,
                    "bytesOut" to stats.bytesOut,
                    "downloadSpeedBps" to stats.downloadSpeedBps,
                    "uploadSpeedBps" to stats.uploadSpeedBps,
                    "durationSeconds" to stats.durationSeconds
                )
                statsEventSink?.success(map)
            }
        }
    }

    fun setActivity(act: Activity?) {
        activity = act
    }

    override fun prepare(callback: (Result<Boolean>) -> Unit) {
        val currentActivity = activity
        if (currentActivity == null) {
            callback(Result.failure(IllegalStateException("Activity is null")))
            return
        }

        val intent = VpnService.prepare(currentActivity)
        if (intent == null) {
            // Already authorized by user
            callback(Result.success(true))
        } else {
            pendingPrepareCallback = callback
            currentActivity.startActivityForResult(intent, VPN_PREPARE_REQUEST_CODE)
        }
    }

    override fun connect(profile: VpnProfilePayload, callback: (Result<Boolean>) -> Unit) {
        scope.launch {
            try {
                val engine = engineFactory.getEngineForProtocol(profile.protocol)
                val success = engine.connect(profile)
                callback(Result.success(success))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun disconnect(callback: (Result<Boolean>) -> Unit) {
        scope.launch {
            try {
                val engine = engineFactory.getEngineForProtocol("ovpn")
                val success = engine.disconnect()
                callback(Result.success(success))
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun getStatus(): VpnStatusPayload {
        val status = RamezVpnService.currentStatus.value
        return VpnStatusPayload(
            state = status.value,
            connectedServerName = RamezVpnService.activeServer.value
        )
    }

    override fun listEngines(): List<VpnEngineInfo> {
        return engineFactory.listEngines()
    }
}
