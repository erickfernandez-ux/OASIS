package com.example.oasis

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
	private val privacyChannelName = "oasis/privacy"

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)
		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, privacyChannelName)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"setSecureFlag" -> {
						val enabled = call.argument<Boolean>("enabled") ?: false
						if (enabled) {
							window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
						} else {
							window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
						}
						result.success(null)
					}
					else -> result.notImplemented()
				}
			}
	}
}
