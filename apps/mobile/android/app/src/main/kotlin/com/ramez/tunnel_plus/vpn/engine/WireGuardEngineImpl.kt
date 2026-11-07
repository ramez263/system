package com.ramez.tunnel_plus.vpn.engine

import android.content.Context
import android.content.Intent
import com.ramez.tunnel_plus.vpn.bridge.VpnProfilePayload
import com.ramez.tunnel_plus.vpn.model.ConnectionStatus
import com.ramez.tunnel_plus.vpn.model.TrafficStats
import com.ramez.tunnel_plus.vpn.service.RamezVpnService
import kotlinx.coroutines.flow.StateFlow

/**
 * High-performance WireGuard VPN Engine.
 * Supports standard WireGuard INI profiles ([Interface] and [Peer]).
 */
class WireGuardEngineImpl(private val context: Context) : VpnEngine {
    override val id: String = "wireguard_native_core"
    override val name: String = "WireGuard Modern Tunnel Engine"
    override val version: String = "1.0.2024"

    override val status: StateFlow<ConnectionStatus> = RamezVpnService.currentStatus
    override val stats: StateFlow<TrafficStats> = RamezVpnService.currentStats

    data class ParsedWireGuardConfig(
        val privateKey: String = "",
        val address: String = "10.0.0.2/32",
        val dns: List<String> = listOf("1.1.1.1", "1.0.0.1"),
        val mtu: Int = 1420,
        val peerPublicKey: String = "",
        val endpointHost: String = "",
        val endpointPort: Int = 51820,
        val allowedIps: List<String> = listOf("0.0.0.0/0"),
        val persistentKeepalive: Int = 25
    )

    override suspend fun connect(profile: VpnProfilePayload): Boolean {
        val parsed = parseWireGuardConfig(profile.rawPayload, profile.serverAddress, profile.serverPort.toInt())

        val dnsToUse = if (profile.dnsServers.isNotEmpty()) profile.dnsServers else parsed.dns

        val intent = Intent(context, RamezVpnService::class.java).apply {
            action = RamezVpnService.ACTION_CONNECT
            putExtra(RamezVpnService.EXTRA_PROFILE_NAME, profile.name)
            putExtra(RamezVpnService.EXTRA_PROTOCOL, "wireguard")
            putExtra(RamezVpnService.EXTRA_SERVER_HOST, if (parsed.endpointHost.isNotEmpty()) parsed.endpointHost else profile.serverAddress)
            putExtra(RamezVpnService.EXTRA_SERVER_PORT, if (parsed.endpointPort > 0) parsed.endpointPort else profile.serverPort.toInt())
            putExtra(RamezVpnService.EXTRA_MTU, parsed.mtu)
            putExtra(RamezVpnService.EXTRA_INTERFACE_ADDRESS, parsed.address)
            putStringArrayListExtra(RamezVpnService.EXTRA_ALLOWED_IPS, ArrayList(parsed.allowedIps))
            putStringArrayListExtra(RamezVpnService.EXTRA_DNS_SERVERS, ArrayList(dnsToUse))
            putExtra(RamezVpnService.EXTRA_BYPASS_LAN, profile.bypassLan)
            putStringArrayListExtra(RamezVpnService.EXTRA_EXCLUDED_APPS, ArrayList(profile.excludedApps))
        }
        context.startService(intent)
        return true
    }

    override suspend fun disconnect(): Boolean {
        val intent = Intent(context, RamezVpnService::class.java).apply {
            action = RamezVpnService.ACTION_DISCONNECT
        }
        context.startService(intent)
        return true
    }

    override fun supports(protocol: String): Boolean {
        val proto = protocol.lowercase().trim()
        return proto == "wireguard" || proto == "wg"
    }

    /**
     * Parses standard WireGuard .conf content
     */
    fun parseWireGuardConfig(configText: String, defaultHost: String, defaultPort: Int): ParsedWireGuardConfig {
        var privateKey = ""
        var address = "10.0.0.2/32"
        var dnsList = mutableListOf<String>()
        var mtu = 1420
        var peerPublicKey = ""
        var endpointHost = defaultHost
        var endpointPort = defaultPort
        var allowedIps = mutableListOf("0.0.0.0/0")
        var keepalive = 25

        if (configText.isNotBlank()) {
            val lines = configText.lines()
            for (rawLine in lines) {
                val line = rawLine.trim()
                if (line.isEmpty() || line.startsWith("#")) continue

                val parts = line.split("=", limit = 2)
                if (parts.size == 2) {
                    val key = parts[0].trim().lowercase()
                    val value = parts[1].trim()

                    when (key) {
                        "privatekey" -> privateKey = value
                        "address" -> address = value
                        "dns" -> dnsList.addAll(value.split(",").map { it.trim() }.filter { it.isNotEmpty() })
                        "mtu" -> mtu = value.toIntOrNull() ?: 1420
                        "publickey" -> peerPublicKey = value
                        "endpoint" -> {
                            val epParts = value.split(":")
                            if (epParts.size == 2) {
                                endpointHost = epParts[0].trim()
                                endpointPort = epParts[1].trim().toIntOrNull() ?: defaultPort
                            } else {
                                endpointHost = value
                            }
                        }
                        "allowedips" -> {
                            allowedIps.clear()
                            allowedIps.addAll(value.split(",").map { it.trim() }.filter { it.isNotEmpty() })
                        }
                        "persistentkeepalive" -> keepalive = value.toIntOrNull() ?: 25
                    }
                }
            }
        }

        if (dnsList.isEmpty()) {
            dnsList = mutableListOf("1.1.1.1", "1.0.0.1")
        }

        return ParsedWireGuardConfig(
            privateKey = privateKey,
            address = address,
            dns = dnsList,
            mtu = mtu,
            peerPublicKey = peerPublicKey,
            endpointHost = endpointHost,
            endpointPort = endpointPort,
            allowedIps = allowedIps,
            persistentKeepalive = keepalive
        )
    }
}
