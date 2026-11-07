package com.ramez.tunnel_plus.vpn.engine

import android.content.Context
import com.ramez.tunnel_plus.vpn.bridge.VpnEngineInfo

/**
 * Factory and registry for all VPN engines behind the VpnEngine unified interface.
 */
class VpnEngineFactory(context: Context) {
    val openVpnEngine = OpenVpnEngineImpl(context)
    val wireGuardEngine = WireGuardEngineImpl(context)
    val sshTunnelEngine = SshTunnelEngineImpl(context)
    val singBoxEngine = SingBoxEngineImpl(context)

    private val allEngines = listOf(openVpnEngine, wireGuardEngine, sshTunnelEngine, singBoxEngine)

    /**
     * Resolves the appropriate native engine implementation for the specified protocol.
     */
    fun getEngineForProtocol(protocol: String): VpnEngine {
        val proto = protocol.lowercase().trim()
        return allEngines.find { it.supports(proto) } ?: openVpnEngine
    }

    /**
     * Enumerates all registered native VPN core engines.
     */
    fun listEngines(): List<VpnEngineInfo> {
        return listOf(
            VpnEngineInfo(
                id = openVpnEngine.id,
                name = openVpnEngine.name,
                supportedProtocols = listOf("ovpn", "openvpn"),
                version = openVpnEngine.version
            ),
            VpnEngineInfo(
                id = wireGuardEngine.id,
                name = wireGuardEngine.name,
                supportedProtocols = listOf("wireguard", "wg"),
                version = wireGuardEngine.version
            ),
            VpnEngineInfo(
                id = sshTunnelEngine.id,
                name = sshTunnelEngine.name,
                supportedProtocols = listOf("ssh", "direct_ssh", "ssl_ssh"),
                version = sshTunnelEngine.version
            ),
            VpnEngineInfo(
                id = singBoxEngine.id,
                name = singBoxEngine.name,
                supportedProtocols = listOf("vless", "vmess", "trojan", "shadowsocks", "hy2"),
                version = singBoxEngine.version
            )
        )
    }
}
