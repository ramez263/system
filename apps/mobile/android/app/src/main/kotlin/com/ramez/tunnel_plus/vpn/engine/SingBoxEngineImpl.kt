package com.ramez.tunnel_plus.vpn.engine

import android.content.Context
import android.content.Intent
import com.ramez.tunnel_plus.vpn.bridge.VpnProfilePayload
import com.ramez.tunnel_plus.vpn.model.ConnectionStatus
import com.ramez.tunnel_plus.vpn.model.TrafficStats
import com.ramez.tunnel_plus.vpn.service.RamezVpnService
import kotlinx.coroutines.flow.StateFlow

class SingBoxEngineImpl(private val context: Context) : VpnEngine {
    override val id: String = "sing_box_core"
    override val name: String = "sing-box Multi-Protocol Engine"
    override val version: String = "1.10.4"

    override val status: StateFlow<ConnectionStatus> = RamezVpnService.currentStatus
    override val stats: StateFlow<TrafficStats> = RamezVpnService.currentStats

    override suspend fun connect(profile: VpnProfilePayload): Boolean {
        val intent = Intent(context, RamezVpnService::class.java).apply {
            action = RamezVpnService.ACTION_CONNECT
            putExtra(RamezVpnService.EXTRA_PROFILE_NAME, profile.name)
            putExtra(RamezVpnService.EXTRA_PROTOCOL, profile.protocol)
            putExtra(RamezVpnService.EXTRA_SERVER_HOST, profile.serverAddress)
            putExtra(RamezVpnService.EXTRA_SERVER_PORT, profile.serverPort.toInt())
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
        return proto == "vless" || proto == "vmess" || proto == "trojan" || proto == "ss" || proto == "shadowsocks" || proto == "hy2"
    }
}
