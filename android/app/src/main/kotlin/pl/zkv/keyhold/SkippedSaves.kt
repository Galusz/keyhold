package pl.zkv.keyhold

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/// Sites and apps where the user said no to "Save to Keyhold?": Android is
/// not asked to offer it there again. Sites by their domain, apps as
/// `androidapp://package`, as their logins are kept in the vault.
/// Only this phone's list: nothing secret, so it is kept outside the vault.
object SkippedSaves {
    private const val PREFS = "keyhold_autofill"
    private const val KEY = "skipped_saves"

    fun keyOf(domain: String, app: String): String = if (domain.isNotEmpty()) domain else "androidapp://$app"

    fun all(context: Context): Set<String> =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getStringSet(KEY, null)?.toSet() ?: emptySet()

    fun contains(context: Context, key: String) = key in all(context)

    fun add(context: Context, key: String) = put(context, all(context) + key)

    fun remove(context: Context, key: String) = put(context, all(context) - key)

    private fun put(context: Context, keys: Set<String>) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit().putStringSet(KEY, keys).apply()
    }

    /// For the list in Settings: an app by its name, a site by its domain.
    fun label(context: Context, key: String): String {
        if (!key.startsWith("androidapp://")) return key
        val app = key.removePrefix("androidapp://")
        return try {
            val pm = context.packageManager
            pm.getApplicationLabel(pm.getApplicationInfo(app, 0)).toString()
        } catch (e: Exception) {
            app
        }
    }
}

/// The "no" button of Android's "Save to Keyhold?" lands here.
class SkipSaveReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val key = intent.getStringExtra(EXTRA_KEY) ?: return
        if (key.isNotBlank()) SkippedSaves.add(context, key)
    }

    companion object {
        const val EXTRA_KEY = "keyhold.skip"
    }
}
