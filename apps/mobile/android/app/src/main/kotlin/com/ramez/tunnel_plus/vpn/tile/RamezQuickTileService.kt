package com.ramez.tunnel_plus.vpn.tile

import android.content.Intent
import android.net.VpnService
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import com.ramez.tunnel_plus.vpn.service.RamezVpnService

@RequiresApi(Build.VERSION_CODES.N)
class RamezQuickTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        updateTileState()
    }

    override fun onClick() {
        super.onClick()

        if (RamezVpnService.isRunning()) {
            val intent = Intent(this, RamezVpnService::class.java).apply {
                action = RamezVpnService.ACTION_DISCONNECT
            }
            startService(intent)
        } else {
            // Check if VPN permission prepared
            val prepareIntent = VpnService.prepare(this)
            if (prepareIntent == null) {
                val intent = Intent(this, RamezVpnService::class.java).apply {
                    action = RamezVpnService.ACTION_CONNECT
                    putExtra(RamezVpnService.EXTRA_PROFILE_NAME, "Frankfurt Fast-01")
                    putExtra(RamezVpnService.EXTRA_SERVER_HOST, "185.120.40.12")
                    putExtra(RamezVpnService.EXTRA_SERVER_PORT, 1194)
                }
                startService(intent)
            }
        }

        updateTileState()
    }

    private fun updateTileState() {
        val tile = qsTile ?: return
        val isRunning = RamezVpnService.isRunning()

        tile.state = if (isRunning) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        tile.label = if (isRunning) "Ramez (Protected)" else "Ramez Tunnel"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = if (isRunning) "Connected" else "Tap to connect"
        }
        tile.updateTile()
    }
}
