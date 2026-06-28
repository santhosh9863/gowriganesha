package com.srigowriganesha.ganesha_2026

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sankalpa/notifications"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "createNotificationChannel") {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val id = call.argument<String>("id") ?: "default"
                    val name = call.argument<String>("name") ?: "Notifications"
                    val descriptionText = call.argument<String>("description") ?: ""
                    val importance = when (call.argument<Int>("importance") ?: 3) {
                        4 -> NotificationManager.IMPORTANCE_HIGH
                        3 -> NotificationManager.IMPORTANCE_DEFAULT
                        2 -> NotificationManager.IMPORTANCE_LOW
                        else -> NotificationManager.IMPORTANCE_DEFAULT
                    }
                    val channel = NotificationChannel(id, name, importance).apply {
                        description = descriptionText
                    }
                    val manager = getSystemService(NotificationManager::class.java)
                    manager.createNotificationChannel(channel)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
