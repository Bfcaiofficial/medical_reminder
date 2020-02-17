package com.example.medical_reminder

import android.content.Intent
import android.os.Build
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {
    private var forService: Intent? = null

    companion object {
        var mIsServiceRunning = false
        var mIsNotificationSent = false
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);


        forService = Intent(this@MainActivity, MyService::class.java)

        MethodChannel(getFlutterEngine()?.getDartExecutor()?.getBinaryMessenger(), "com.example.lifement").setMethodCallHandler { methodCall, result ->
            if (methodCall.method.equals("startService")) {
                if (!mIsServiceRunning) {
                    startService()
                    result.success("Background Service started ya ngm")
                    mIsServiceRunning = true
                }
            }
        }

        MethodChannel(getFlutterEngine()?.getDartExecutor()?.getBinaryMessenger(), "com.example.lifement2").setMethodCallHandler { methodCall, result ->
            if(methodCall.method == "stopService"){
                mIsServiceRunning = false;
                stopService()
                result.success("Background Service stopped")
            }
        }

        MethodChannel(getFlutterEngine()?.getDartExecutor()?.getBinaryMessenger(), "com.example.lifement.notifications").setMethodCallHandler { methodCall, result ->
            if(methodCall.method == "isNotificationSent"){
                result.success(mIsNotificationSent)
                mIsNotificationSent = false;
            }
        }



    }

    internal fun startService() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(forService)
        } else {
            startService(forService)
        }
    }

    internal fun stopService() {
        stopService(forService)
    }
}
