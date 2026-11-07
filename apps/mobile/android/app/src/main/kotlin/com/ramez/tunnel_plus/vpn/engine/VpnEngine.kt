package com.ramez.tunnel_plus.vpn.engine

import com.ramez.tunnel_plus.vpn.bridge.VpnProfilePayload
import com.ramez.tunnel_plus.vpn.model.ConnectionStatus
import com.ramez.tunnel_plus.vpn.model.TrafficStats
import kotlinx.coroutines.flow.StateFlow

interface VpnEngine {
    val id: String
    val name: String
    val version: String
    val status: StateFlow<ConnectionStatus>
    val stats: StateFlow<TrafficStats>

    suspend fun connect(profile: VpnProfilePayload): Boolean
    suspend fun disconnect(): Boolean
    fun supports(protocol: String): Boolean
}
