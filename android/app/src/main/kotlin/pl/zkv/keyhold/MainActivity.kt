package pl.zkv.keyhold

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.autofill.AutofillManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A FragmentActivity: the fingerprint prompt lives in a fragment.
class MainActivity : FlutterFragmentActivity() {
    private var screenOff: BroadcastReceiver? = null

    override fun onDestroy() {
        screenOff?.let { unregisterReceiver(it) }
        screenOff = null
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Keystore.register(flutterEngine)

        // The screen going dark locks Keyhold, when the fingerprint lock is on.
        val lock = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/lock")
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                lock.invokeMethod("screenOff", null)
            }
        }
        val filter = IntentFilter(Intent.ACTION_SCREEN_OFF)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        screenOff = receiver

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
