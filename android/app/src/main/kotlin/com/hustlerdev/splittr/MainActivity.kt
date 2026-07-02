package com.hustlerdev.splittr

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channel = "com.hustlerdev.splittr/deeplink"
    private var flutterEngine: FlutterEngine? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        this.flutterEngine = flutterEngine
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        sendDeepLink(intent)
    }

    override fun onResume() {
        super.onResume()
        sendDeepLink(intent)
    }

    private fun sendDeepLink(intent: Intent?) {
        val uri = intent?.data?.toString() ?: return
        if (uri == "splittr://add-expense") {
            // Clear so we don't re-send on next resume
            getIntent().data = null
            flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, channel).invokeMethod("deeplink", uri)
            }
        }
    }
}
