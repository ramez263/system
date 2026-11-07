package com.ramez.tunnel_plus.vpn.engine

import android.content.Context
import com.ramez.tunnel_plus.vpn.bridge.VpnEngineInfo

class VpnEngineFactory(context: Context) {
    private val openVpnEngine = OpenVpnEngineImpl(context)
    private val singBoxEngine = SingBoxEngineImpl(context)

    private val allEngines = listOf(openVpnEngine, singBoxEngine)

    fun getEngineForProtocol(protocol: String): VpnEngine {
        return allEngines.find { it.supports(protocol) } ?: openVpnEngine
    }

    fun listEngines(): List<VpnEngineInfo> {
        return listOf(
            VpnEngineInfo(
                id = openVpnEngine.id,
                name = openVpnEngine.name,
                supportedProtocols = listOf("ovpn", "openvpn"),
                version = openVpnEngine.version
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
