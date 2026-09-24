package pl.zkv.keyhold

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveInfo
import android.service.autofill.SaveRequest
import android.widget.RemoteViews
import androidx.annotation.RequiresApi

/// Keyhold as the phone's password filler. The suggestion under a field only
/// says "Keyhold"; nothing leaves the vault until the user taps it and picks a
/// login in [AutofillActivity].
@RequiresApi(Build.VERSION_CODES.O)
class KeyholdAutofillService : AutofillService() {
    private var nextRequest = 0

    override fun onFillRequest(request: FillRequest, cancellationSignal: CancellationSignal, callback: FillCallback) {
        val form = LoginForm.parse(request.fillContexts.map { it.structure })
        if (form.app == packageName || form.ids.isEmpty()) {
            callback.onSuccess(null)
            return
        }

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

        @Suppress("DEPRECATION")
        val dataset = Dataset.Builder(presentation(this, "Keyhold")).apply {
            for (id in form.ids) setValue(id, null)
            setAuthentication(pending.intentSender)
        }.build()

        val response = FillResponse.Builder().addDataset(dataset)
        if (form.passwords.isNotEmpty()) {
            val type = SaveInfo.SAVE_DATA_TYPE_PASSWORD or
                (if (form.usernames.isNotEmpty()) SaveInfo.SAVE_DATA_TYPE_USERNAME else 0)
            val save = SaveInfo.Builder(type, form.passwords.toTypedArray())
            if (form.usernames.isNotEmpty()) save.setOptionalIds(form.usernames.toTypedArray())
            response.setSaveInfo(save.build())
        }
        callback.onSuccess(response.build())
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
        fun presentation(context: Context, text: String) =
            RemoteViews(context.packageName, R.layout.autofill_item).apply {
                setTextViewText(R.id.text, text)
            }
    }
}
