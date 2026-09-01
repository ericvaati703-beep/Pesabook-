package com.example.pesabook1

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.pesabook1/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "openSms" -> {
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")

                    if (phoneNumber.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    try {
                        val smsIntent = Intent(
                            Intent.ACTION_SENDTO,
                            Uri.parse("smsto:${Uri.encode(phoneNumber)}")
                        )

                        smsIntent.putExtra(
                            "sms_body",
                            message ?: ""
                        )

                        if (smsIntent.resolveActivity(packageManager) != null) {
                            startActivity(smsIntent)
                            result.success(true)
                        } else {
                            result.success(false)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}