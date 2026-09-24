package pl.zkv.keyhold

import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK
import androidx.biometric.BiometricManager.Authenticators.DEVICE_CREDENTIAL
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// The phone's own fingerprint panel: under the system's icon and app name the
/// title and one line Keyhold sends in the user's language, the rest is the
/// system's. The phone's PIN or pattern stands in when the finger fails.
object Fingerprint {
    private const val ALLOWED = BIOMETRIC_WEAK or DEVICE_CREDENTIAL

    fun register(activity: FragmentActivity, engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "keyhold/fingerprint")
            .setMethodCallHandler { call, result ->
                if (call.method != "ask") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (BiometricManager.from(activity).canAuthenticate(ALLOWED) != BiometricManager.BIOMETRIC_SUCCESS) {
                    result.success(false)
                    return@setMethodCallHandler
                }
                val callback = object : BiometricPrompt.AuthenticationCallback() {
                    override fun onAuthenticationSucceeded(outcome: BiometricPrompt.AuthenticationResult) {
                        result.success(true)
                    }

                    override fun onAuthenticationError(code: Int, message: CharSequence) {
                        result.success(false)
                    }
                }
                BiometricPrompt(activity, ContextCompat.getMainExecutor(activity), callback).authenticate(
                    BiometricPrompt.PromptInfo.Builder()
                        .setTitle(call.argument<String>("title") ?: "Keyhold")
                        .setSubtitle(call.argument<String>("hint"))
                        .setAllowedAuthenticators(ALLOWED)
                        .build()
                )
            }
    }
}
