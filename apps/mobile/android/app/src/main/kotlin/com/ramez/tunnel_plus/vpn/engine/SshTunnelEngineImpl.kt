package com.ramez.tunnel_plus.vpn.engine

import android.content.Context
import android.content.Intent
import com.ramez.tunnel_plus.vpn.bridge.VpnProfilePayload
import com.ramez.tunnel_plus.vpn.model.ConnectionStatus
import com.ramez.tunnel_plus.vpn.model.TrafficStats
import com.ramez.tunnel_plus.vpn.service.RamezVpnService
import kotlinx.coroutines.flow.StateFlow

/**
 * SSH Tunnel & HTTP Payload Injector VPN Engine.
 * Supports Direct SSH, SSL/TLS SNI bug hosts, and custom HTTP header payload injection.
 */
class SshTunnelEngineImpl(private val context: Context) : VpnEngine {
    override val id: String = "ssh_tunnel_core"
    override val name: String = "SSH Secure Shell & Injector Engine"
    override val version: String = "0.9.2"

    override val status: StateFlow<ConnectionStatus> = RamezVpnService.currentStatus
    override val stats: StateFlow<TrafficStats> = RamezVpnService.currentStats

    data class ParsedSshConfig(
        val host: String = "",
        val port: Int = 22,
        val username: String = "",
        val password: String = "",
        val payload: String = "",
        val sni: String = "",
        val isDirect: Boolean = true
    )

    override suspend fun connect(profile: VpnProfilePayload): Boolean {
        val parsed = parseSshConfig(profile.rawPayload, profile.serverAddress, profile.serverPort.toInt())

        val intent = Intent(context, RamezVpnService::class.java).apply {
            action = RamezVpnService.ACTION_CONNECT
            putExtra(RamezVpnService.EXTRA_PROFILE_NAME, profile.name)
            putExtra(RamezVpnService.EXTRA_PROTOCOL, "ssh")
            putExtra(RamezVpnService.EXTRA_SERVER_HOST, if (parsed.host.isNotEmpty()) parsed.host else profile.serverAddress)
            putExtra(RamezVpnService.EXTRA_SERVER_PORT, if (parsed.port > 0) parsed.port else profile.serverPort.toInt())
            putExtra(RamezVpnService.EXTRA_SSH_USERNAME, parsed.username)
            putExtra(RamezVpnService.EXTRA_SSH_PAYLOAD, parsed.payload)
            putExtra(RamezVpnService.EXTRA_SSH_SNI, parsed.sni)
            putStringArrayListExtra(RamezVpnService.EXTRA_DNS_SERVERS, ArrayList(profile.dnsServers))
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
        return proto == "ssh" || proto == "direct_ssh" || proto == "ssl_ssh"
    }

    /**
     * Parses SSH config content or SSH URI (ssh://user:pass@host:port)
     */
    fun parseSshConfig(configText: String, defaultHost: String, defaultPort: Int): ParsedSshConfig {
        var host = defaultHost
        var port = if (defaultPort > 0) defaultPort else 22
        var username = ""
        var password = ""
        var payload = ""
        var sni = ""

        val trimmed = configText.trim()
        if (trimmed.startsWith("ssh://", ignoreCase = true)) {
            val withoutScheme = trimmed.substring(6)
            val atIndex = withoutScheme.indexOf('@')
            if (atIndex != -1) {
                val userPass = withoutScheme.substring(0, atIndex).split(":")
                username = userPass[0]
                if (userPass.size > 1) password = userPass[1]

                val hostPort = withoutScheme.substring(atIndex + 1).split(":")
                host = hostPort[0]
                if (hostPort.size > 1) port = hostPort[1].toIntOrNull() ?: 22
            }
        } else {
            // Key-value INI or lines parser
            val lines = trimmed.lines()
            for (rawLine in lines) {
                val line = rawLine.trim()
                if (line.isEmpty() || line.startsWith("#")) continue

                val parts = line.split("=", limit = 2)
                if (parts.size == 2) {
                    val key = parts[0].trim().lowercase()
                    val value = parts[1].trim()

                    when (key) {
                        "host", "server" -> host = value
                        "port" -> port = value.toIntOrNull() ?: 22
                        "user", "username" -> username = value
                        "pass", "password" -> password = value
                        "payload" -> payload = value
                        "sni" -> sni = value
                    }
                }
            }
        }

        return ParsedSshConfig(
            host = host,
            port = port,
            username = username,
            password = password,
            payload = payload,
            sni = sni,
            isDirect = payload.isEmpty() && sni.isEmpty()
        )
    }
}
