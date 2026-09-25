package pl.zkv.keyhold

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.Uri
import android.os.Build
import android.print.PrintAttributes
import android.print.PrintManager
import android.provider.Settings
import android.view.autofill.AutofillManager
import android.view.WindowManager
import android.webkit.WebView
import android.webkit.WebViewClient
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// A FragmentActivity: the fingerprint prompt lives in a fragment.
class MainActivity : FlutterFragmentActivity() {
    private var screenOff: BroadcastReceiver? = null

    // The page being printed: kept until the print screen is done with it.
    private var printing: WebView? = null

    override fun onDestroy() {
        screenOff?.let { unregisterReceiver(it) }
        screenOff = null
        super.onDestroy()
    }

    @Deprecated("The folder window answers here; Flutter's own screens use the same path.")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (!Folders.onResult(this, requestCode, resultCode, data)) super.onActivityResult(requestCode, resultCode, data)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Keystore.register(flutterEngine)
        Fingerprint.register(this, flutterEngine)
        Folders.register(this, flutterEngine)

        // The screen going dark locks Keyhold, when the fingerprint lock is on.
        val lock = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/lock")
        // With the fingerprint lock on, no screenshot and no picture in the recent apps.
        lock.setMethodCallHandler { call, result ->
            if (call.method == "secure") {
                if (call.arguments == true) {
                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                } else {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                // A dark screen ends the five minutes the owner's finger holds.
                Fingerprint.forget()
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

        // The recovery sheet goes to the phone's own print screen, "Save as PDF" included.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/print")
            .setMethodCallHandler { call, result ->
                val name = call.argument<String>("name") ?: "Keyhold"
                val view = WebView(this)
                view.webViewClient = object : WebViewClient() {
                    override fun onPageFinished(page: WebView, url: String?) {
                        getSystemService(PrintManager::class.java)
                            .print(name, page.createPrintDocumentAdapter(name), PrintAttributes.Builder().build())
                    }
                }
                view.loadDataWithBaseURL(null, call.argument<String>("html") ?: "", "text/html", "UTF-8", null)
                printing = view
                result.success(null)
            }

        // A copy of the vault file handed to the app the user picks: mail, chat, Files, Drive.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/share")
            .setMethodCallHandler { call, result ->
                val file = java.io.File(call.argument<String>("path")!!)
                val uri = androidx.core.content.FileProvider.getUriForFile(this, "$packageName.files", file)
                val send = Intent(Intent.ACTION_SEND)
                    .setType("application/octet-stream")
                    .putExtra(Intent.EXTRA_STREAM, uri)
                    .putExtra(Intent.EXTRA_SUBJECT, file.name)
                    .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                startActivity(Intent.createChooser(send, call.argument<String>("title")))
                result.success(null)
            }

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
