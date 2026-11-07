package com.ramez.tunnel_plus

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import com.ramez.tunnel_plus.vpn.bridge.VpnBridgeHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private var vpnBridgeHandler: VpnBridgeHandler? = null

    companion object {
        private const val SECURITY_CHANNEL = "com.ramez.tunnel_plus/security"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        vpnBridgeHandler = VpnBridgeHandler(
            context = applicationContext,
            activity = this,
            messenger = flutterEngine.dartExecutor.binaryMessenger
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecureScreen" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    runOnUiThread {
                        if (enabled) {
                            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                        result.success(true)
                    }
                }
                "checkRootStatus" -> {
                    val isRooted = checkRootMethod()
                    result.success(isRooted)
                }
                "isBatteryOptimizationIgnored" -> {
                    val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
                    val isIgnored = powerManager?.isIgnoringBatteryOptimizations(packageName) ?: false
                    result.success(isIgnored)
                }
                "requestIgnoreBatteryOptimization" -> {
                    try {
                        val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", e.localizedMessage, null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun checkRootMethod(): Boolean {
        val paths = arrayOf(
            "/system/app/Superuser.apk",
            "/sbin/su",
            "/system/bin/su",
            "/system/xbin/su",
            "/data/local/xbin/su",
            "/data/local/bin/su",
            "/system/sd/xbin/su",
            "/system/bin/failsafe/su",
            "/data/local/su"
        )
        for (path in paths) {
            if (File(path).exists()) return true
        }
        val buildTags = Build.TAGS
        if (buildTags != null && buildTags.contains("test-keys")) {
            return true
        }
        return false
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
