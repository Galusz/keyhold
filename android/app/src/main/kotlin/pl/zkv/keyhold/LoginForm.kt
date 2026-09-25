package pl.zkv.keyhold

import android.app.assist.AssistStructure
import android.os.Build
import android.text.InputType
import android.view.View
import android.view.autofill.AutofillId
import androidx.annotation.RequiresApi

/// The login fields on a screen and whose screen it is: a web page's domain
/// (in a browser) or an app's package name.
@RequiresApi(Build.VERSION_CODES.O)
class LoginForm(
    val usernames: List<AutofillId>,
    val passwords: List<AutofillId>,
    val codes: List<AutofillId>,
    val domain: String,
    val app: String,
    val username: String?,
    val password: String?,
) {
    val ids get() = usernames + passwords + codes

    private enum class Kind { USERNAME, PASSWORD, CODE, TEXT }

    companion object {
        private val USER_WORDS = Regex("user|login|e-?mail|account|identifier|nazwa|konto|phone|telefon")
        private val CODE_WORDS = Regex("one.?time|otp|totp|2fa|mfa|two.?factor|authenticat|verification|security.?code|\\bcode\\b|kod")
        private val NOT_CODE = Regex("zip|postal|post.?code|poczt|promo|coupon|voucher|country|captcha|discount|rabat")

        // Where browsers keep the page address, for pages that do not report
        // their domain themselves.
        private val URL_BARS = setOf(
            "url_bar", "mozac_browser_toolbar_url_view", "location_bar_edit_text",
            "url_field", "url", "address_bar_edit_text",
        )

        // Only a browser's address bar tells the page: any app can show a field named "url".
        private val BROWSERS = setOf(
            "com.android.chrome", "com.chrome.beta", "com.chrome.dev", "org.chromium.chrome",
            "org.mozilla.firefox", "org.mozilla.firefox_beta", "org.mozilla.fenix", "org.mozilla.focus",
            "com.microsoft.emmx", "com.brave.browser", "com.opera.browser", "com.opera.mini.native",
            "com.sec.android.app.sbrowser", "com.vivaldi.browser", "com.duckduckgo.mobile.android",
            "com.kiwibrowser.browser", "com.mi.globalbrowser",
        )

        /// Reads every screen of the session, newest last: a two-step login
        /// asks for the username on one screen and the password on the next.
        fun parse(structures: List<AssistStructure>): LoginForm {
            val last = structures.last()
            val nodes = nodesOf(last)

            // Only a browser is believed about which site is open: any other app
            // could name a bank's domain for a page it shows itself.
            val browser = last.activityComponent?.packageName in BROWSERS
            var domain = if (browser) nodes.firstNotNullOfOrNull { it.webDomain?.takeIf(String::isNotBlank) } ?: "" else ""
            if (domain.isEmpty() && browser) {
                domain = hostOf(nodes.firstOrNull { it.idEntry in URL_BARS }?.text?.toString() ?: "")
            }
            domain = domain.lowercase().removePrefix("www.")

            val usernames = mutableListOf<AutofillId>()
            val passwords = mutableListOf<AutofillId>()
            val codes = mutableListOf<AutofillId>()
            var username: String? = null
            var password: String? = null
            var textBefore: AssistStructure.ViewNode? = null

            for (node in nodes) {
                val id = node.autofillId ?: continue
                when (kindOf(node)) {
                    Kind.PASSWORD -> {
                        passwords += id
                        password = valueOf(node) ?: password
                        // A username field nobody labelled: the text field right before.
                        val before = textBefore
                        if (usernames.isEmpty() && before != null) {
                            usernames += before.autofillId!!
                            username = valueOf(before)
                        }
                    }
                    Kind.USERNAME -> {
                        usernames += id
                        username = valueOf(node) ?: username
                    }
                    Kind.CODE -> codes += id
                    Kind.TEXT -> if (node.idEntry !in URL_BARS) textBefore = node
                    null -> {}
                }
            }

            // The username typed on an earlier screen of a two-step login.
            if (username.isNullOrEmpty()) {
                for (earlier in structures.dropLast(1).reversed()) {
                    username = nodesOf(earlier).filter { kindOf(it) == Kind.USERNAME }.firstNotNullOfOrNull { valueOf(it) }
                    if (!username.isNullOrEmpty()) break
                }
            }

            return LoginForm(
                usernames, passwords, codes, domain,
                last.activityComponent?.packageName ?: "",
                username, password,
            )
        }

        private fun nodesOf(structure: AssistStructure): List<AssistStructure.ViewNode> {
            val out = mutableListOf<AssistStructure.ViewNode>()
            fun collect(node: AssistStructure.ViewNode) {
                out += node
                for (i in 0 until node.childCount) collect(node.getChildAt(i))
            }
            for (i in 0 until structure.windowNodeCount) collect(structure.getWindowNodeAt(i).rootViewNode)
            return out
        }

        private fun valueOf(node: AssistStructure.ViewNode): String? {
            val value = node.autofillValue
            val text = if (value != null && value.isText) value.textValue.toString() else node.text?.toString()
            return text?.takeIf { it.isNotEmpty() }
        }

        private fun kindOf(node: AssistStructure.ViewNode): Kind? {
            if (node.autofillId == null) return null
            val html = node.htmlInfo
            val attrs = html?.attributes
                ?.associate { (it.first ?: "").lowercase() to (it.second ?: "").lowercase() }
                ?: emptyMap()
            val editable = html?.tag.equals("input", ignoreCase = true) ||
                node.className?.contains("EditText") == true ||
                node.autofillType == View.AUTOFILL_TYPE_TEXT
            if (!editable) return null
            val type = attrs["type"] ?: ""
            if (type in setOf("hidden", "submit", "button", "checkbox", "radio", "search")) return null

            val hints = node.autofillHints?.map { it.lowercase() } ?: emptyList()
            val words = listOf(
                node.idEntry, node.hint, attrs["name"], attrs["id"], attrs["autocomplete"],
                attrs["placeholder"], attrs["aria-label"], hints.joinToString(" "),
            ).joinToString(" ") { it ?: "" }.lowercase()

            if (hints.any { "otp" in it || "onetimecode" in it.replace("-", "") } ||
                attrs["autocomplete"] == "one-time-code" ||
                (CODE_WORDS.containsMatchIn(words) && !NOT_CODE.containsMatchIn(words))
            ) return Kind.CODE

            val cls = node.inputType and InputType.TYPE_MASK_CLASS
            val variation = node.inputType and InputType.TYPE_MASK_VARIATION
            val isPassword = hints.any { "password" in it } || type == "password" ||
                (cls == InputType.TYPE_CLASS_TEXT && variation in setOf(
                    InputType.TYPE_TEXT_VARIATION_PASSWORD,
                    InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD,
                    InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD,
                )) ||
                (cls == InputType.TYPE_CLASS_NUMBER && variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD)
            if (isPassword) return Kind.PASSWORD

            val isUser = hints.any { it == "username" || it == "emailaddress" || it == "email" } ||
                type == "email" ||
                (cls == InputType.TYPE_CLASS_TEXT && variation in setOf(
                    InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS,
                    InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS,
                )) ||
                USER_WORDS.containsMatchIn(words)
            return if (isUser) Kind.USERNAME else Kind.TEXT
        }

        private fun hostOf(text: String): String {
            val trimmed = text.trim()
            if (trimmed.isEmpty() || trimmed.contains(' ')) return ""
            val withScheme = if ("://" in trimmed) trimmed else "https://$trimmed"
            return try {
                java.net.URI(withScheme).host ?: ""
            } catch (e: Exception) {
                ""
            }
        }
    }
}
