package pl.zkv.keyhold

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CancellationSignal
import android.os.Handler
import android.os.Looper
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveInfo
import android.service.autofill.SaveRequest
import android.view.View
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import java.util.regex.Pattern

/// Keyhold as the phone's password filler: the logins for the site or app
/// right under the field, plus "Keyhold" to search the whole vault.
@RequiresApi(Build.VERSION_CODES.O)
class KeyholdAutofillService : AutofillService() {
    private var nextRequest = 0
    private val main = Handler(Looper.getMainLooper())

    // A headless copy of the app's Dart side opens the vault and finds the logins.
    private var engine: FlutterEngine? = null
    private var lookup: MethodChannel? = null
    private var ready = false
    private val waiting = mutableListOf<() -> Unit>()

    override fun onDestroy() {
        engine?.destroy()
        engine = null
        lookup = null
        ready = false
        waiting.clear()
        super.onDestroy()
    }

    private fun whenReady(action: () -> Unit) {
        if (ready) {
            action()
            return
        }
        waiting += action
        if (engine != null) return

        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, null)
        val started = FlutterEngine(applicationContext)
        Keystore.register(started)
        lookup = MethodChannel(started.dartExecutor.binaryMessenger, "keyhold/autofill-lookup").apply {
            setMethodCallHandler { call, result ->
                if (call.method == "ready") {
                    ready = true
                    waiting.forEach { it() }
                    waiting.clear()
                }
                result.success(null)
            }
        }
        started.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "autofillLookupMain")
        )
        engine = started
    }

    override fun onFillRequest(request: FillRequest, cancellationSignal: CancellationSignal, callback: FillCallback) {
        val form = LoginForm.parse(request.fillContexts.map { it.structure })
        if (form.app == packageName || form.ids.isEmpty()) {
            callback.onSuccess(null)
            return
        }

        var answered = false
        fun answer(logins: List<Map<*, *>>) {
            if (answered) return
            answered = true
            callback.onSuccess(response(form, logins))
        }
        // Android waits only a few seconds; then at least "Keyhold" shows up.
        main.postDelayed({ answer(emptyList()) }, 3000)
        whenReady {
            lookup?.invokeMethod(
                "lookup",
                mapOf("domain" to form.domain, "app" to form.app, "wantsCode" to form.codes.isNotEmpty()),
                object : MethodChannel.Result {
                    override fun success(result: Any?) =
                        answer((result as? List<*>)?.filterIsInstance<Map<*, *>>() ?: emptyList())

                    override fun error(code: String, message: String?, details: Any?) = answer(emptyList())
                    override fun notImplemented() = answer(emptyList())
                },
            )
        }
    }

    @Suppress("DEPRECATION")
    private fun response(form: LoginForm, logins: List<Map<*, *>>): FillResponse {
        val response = FillResponse.Builder()

        for (login in logins.take(6)) {
            val username = login["username"] as? String
            val dataset = Dataset.Builder(presentation(this, login["title"] as? String ?: "", username))
            var any = false
            fun put(ids: List<android.view.autofill.AutofillId>, value: String?, secret: Boolean) {
                if (value.isNullOrEmpty()) return
                for (id in ids) {
                    // Typing in a password or code field hides the list instead of
                    // matching it against the saved secret.
                    if (secret && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        dataset.setValue(id, AutofillValue.forText(value), null as Pattern?)
                    } else {
                        dataset.setValue(id, AutofillValue.forText(value))
                    }
                    any = true
                }
            }
            put(form.usernames, username, secret = false)
            put(form.passwords, login["password"] as? String, secret = true)
            put(form.codes, login["code"] as? String, secret = true)
            if (any) response.addDataset(dataset.build())
        }

        // "Keyhold": the whole vault, searchable, on a screen of its own.
        val intent = Intent(this, AutofillActivity::class.java)
            .putExtra(AutofillActivity.EXTRA_DOMAIN, form.domain)
            .putExtra(AutofillActivity.EXTRA_APP, form.app)
            .putParcelableArrayListExtra(AutofillActivity.EXTRA_USERNAMES, ArrayList(form.usernames))
            .putParcelableArrayListExtra(AutofillActivity.EXTRA_PASSWORDS, ArrayList(form.passwords))
            .putParcelableArrayListExtra(AutofillActivity.EXTRA_CODES, ArrayList(form.codes))
        // The system adds the screen's structure to it, so it has to stay mutable.
        val pending = PendingIntent.getActivity(
            this, nextRequest++, intent,
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_CANCEL_CURRENT,
        )
        val search = Dataset.Builder(presentation(this, "Keyhold", "Search all logins")).apply {
            for (id in form.ids) setValue(id, null)
            setAuthentication(pending.intentSender)
        }.build()
        response.addDataset(search)

        if (form.passwords.isNotEmpty()) {
            val type = SaveInfo.SAVE_DATA_TYPE_PASSWORD or
                (if (form.usernames.isNotEmpty()) SaveInfo.SAVE_DATA_TYPE_USERNAME else 0)
            val save = SaveInfo.Builder(type, form.passwords.toTypedArray())
            if (form.usernames.isNotEmpty()) save.setOptionalIds(form.usernames.toTypedArray())
            response.setSaveInfo(save.build())
        }
        return response.build()
    }

    /// Android asked "Save to Keyhold?" and the user said yes.
    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        val form = LoginForm.parse(request.fillContexts.map { it.structure })
        val password = form.password
        if (password.isNullOrEmpty() || form.app == packageName) {
            callback.onSuccess()
            return
        }
        val intent = Intent(this, AutofillActivity::class.java)
            .putExtra(AutofillActivity.EXTRA_SAVE, true)
            .putExtra(AutofillActivity.EXTRA_DOMAIN, form.domain)
            .putExtra(AutofillActivity.EXTRA_APP, form.app)
            .putExtra(AutofillActivity.EXTRA_LABEL, appLabel(form.app))
            .putExtra(AutofillActivity.EXTRA_USERNAME, form.username ?: "")
            .putExtra(AutofillActivity.EXTRA_PASSWORD, password)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val pending = PendingIntent.getActivity(
                this, nextRequest++, intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_CANCEL_CURRENT,
            )
            callback.onSuccess(pending.intentSender)
        } else {
            startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            callback.onSuccess()
        }
    }

    private fun appLabel(app: String): String = try {
        packageManager.getApplicationLabel(packageManager.getApplicationInfo(app, 0)).toString()
    } catch (e: Exception) {
        app
    }

    companion object {
        fun presentation(context: Context, text: String, sub: String? = null) =
            RemoteViews(context.packageName, R.layout.autofill_item).apply {
                setTextViewText(R.id.text, text)
                if (sub.isNullOrEmpty()) {
                    setViewVisibility(R.id.sub, View.GONE)
                } else {
                    setTextViewText(R.id.sub, sub)
                }
            }
    }
}
