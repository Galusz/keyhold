package pl.zkv.keyhold

import android.content.Intent
import android.os.Build
import android.service.autofill.Dataset
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager
import android.view.autofill.AutofillValue
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// The small Keyhold screen behind the "Keyhold" suggestion: the user picks a
/// login (or it keeps one Android offered to save), then it closes.
@RequiresApi(Build.VERSION_CODES.O)
open class AutofillActivity : FlutterFragmentActivity() {
    override fun getDartEntrypointFunctionName() = "autofillMain"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Keystore.register(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "keyhold/autofill")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "request" -> result.success(request())
                    "fill" -> {
                        val args = call.arguments as Map<*, *>
                        fill(args["username"] as String?, args["password"] as String?, args["code"] as String?)
                        result.success(null)
                    }
                    "close" -> {
                        setResult(RESULT_CANCELED)
                        finish()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun request(): Map<String, Any?> {
        val save = intent.getBooleanExtra(EXTRA_SAVE, false)
        return mapOf(
            "mode" to if (save) "save" else "fill",
            "domain" to (intent.getStringExtra(EXTRA_DOMAIN) ?: ""),
            "app" to (intent.getStringExtra(EXTRA_APP) ?: ""),
            "label" to (intent.getStringExtra(EXTRA_LABEL) ?: ""),
            "entry" to intent.getStringExtra(EXTRA_ENTRY),
            "username" to if (save) intent.getStringExtra(EXTRA_USERNAME) else null,
            "password" to if (save) intent.getStringExtra(EXTRA_PASSWORD) else null,
            "wantsCode" to ids(EXTRA_CODES).isNotEmpty(),
        )
    }

    @Suppress("DEPRECATION")
    private fun ids(key: String): List<AutofillId> =
        intent.getParcelableArrayListExtra<AutofillId>(key) ?: emptyList()

    @Suppress("DEPRECATION")
    private fun fill(username: String?, password: String?, code: String?) {
        val dataset = Dataset.Builder(KeyholdAutofillService.presentation(this, username ?: "Keyhold"))
        var any = false
        fun put(key: String, value: String?) {
            if (value.isNullOrEmpty()) return
            for (id in ids(key)) {
                dataset.setValue(id, AutofillValue.forText(value))
                any = true
            }
        }
        put(EXTRA_USERNAMES, username)
        put(EXTRA_PASSWORDS, password)
        put(EXTRA_CODES, code)
        if (any) {
            setResult(RESULT_OK, Intent().putExtra(AutofillManager.EXTRA_AUTHENTICATION_RESULT, dataset.build()))
        } else {
            setResult(RESULT_CANCELED)
        }
        finish()
    }

    companion object {
        const val EXTRA_DOMAIN = "keyhold.domain"
        const val EXTRA_APP = "keyhold.app"
        const val EXTRA_LABEL = "keyhold.label"
        const val EXTRA_ENTRY = "keyhold.entry"
        const val EXTRA_USERNAMES = "keyhold.usernames"
        const val EXTRA_PASSWORDS = "keyhold.passwords"
        const val EXTRA_CODES = "keyhold.codes"
        const val EXTRA_SAVE = "keyhold.save"
        const val EXTRA_USERNAME = "keyhold.username"
        const val EXTRA_PASSWORD = "keyhold.password"
    }
}

/// Fills a two-factor code without a screen of its own: see-through, it only
/// shows up when it has to wait a moment for the next code.
@RequiresApi(Build.VERSION_CODES.O)
class CodeActivity : AutofillActivity() {
    override fun getBackgroundMode() = FlutterActivityLaunchConfigs.BackgroundMode.transparent
}
