package pl.zkv.keyhold

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.autofill.AutofillManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Keystore.register(flutterEngine)

        // Settings: is Keyhold the phone's password filler, and the system switch to make it one.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/autofill-settings")
            .setMethodCallHandler { call, result ->
                val manager = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    getSystemService(AutofillManager::class.java)
                } else {
                    null
                }
                when (call.method) {
                    "state" -> result.success(
                        when {
                            manager == null || !manager.isAutofillSupported -> "unsupported"
                            manager.hasEnabledAutofillServices() -> "on"
                            else -> "off"
                        }
                    )
                    "enable" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            startActivity(
                                Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE)
                                    .setData(Uri.parse("package:$packageName"))
                            )
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
