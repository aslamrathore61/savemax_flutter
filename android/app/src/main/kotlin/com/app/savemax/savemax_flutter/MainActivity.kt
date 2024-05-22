package com.app.savemax.savemax_flutter

import android.content.ComponentName
import android.content.Context
import android.content.pm.PackageManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.app.savemax_MainActivity"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "AppIconChange") {
                    val message = call.arguments as String
                    if (message.equals(".MainActivityA")) {
                        setIcon(this, "$packageName.MainActivityA");
                    }else {
                        setIcon(this, "$packageName.MainActivityB");
                    }
                    // setIcon(this,"$packageName$message")
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
    }


    private fun setIcon(
        context: Context,
        componentName: String,
    ) {
        val packageManager = context.packageManager

        gregAppIcons.filter {
            it.component != componentName
        }.forEach {
            packageManager.setComponentEnabledSetting(
                ComponentName(context, it.component),
                PackageManager.COMPONENT_ENABLED_STATE_DISABLED,
                PackageManager.DONT_KILL_APP,
            )
        }

        packageManager.setComponentEnabledSetting(
            ComponentName(context, componentName),
            PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
            PackageManager.DONT_KILL_APP,
        )
    }


}
