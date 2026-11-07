package com.ramez.tunnel_plus

import android.app.Activity
import android.content.Intent
import com.ramez.tunnel_plus.vpn.bridge.VpnBridgeHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var vpnBridgeHandler: VpnBridgeHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        vpnBridgeHandler = VpnBridgeHandler(
            context = applicationContext,
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger
        )
    }

    override fun onResume() {
        super.onResume()
        vpnBridgeHandler?.setActivity(this)
    }

    override fun onDestroy() {
        vpnBridgeHandler?.setActivity(null)
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == VpnBridgeHandler.VPN_PREPARE_REQUEST_CODE) {
            val isAuthorized = (resultCode == Activity.RESULT_OK)
            VpnBridgeHandler.pendingPrepareCallback?.invoke(Result.success(isAuthorized))
            VpnBridgeHandler.pendingPrepareCallback = null
        }
    }
}
