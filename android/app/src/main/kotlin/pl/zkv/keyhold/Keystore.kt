package pl.zkv.keyhold

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec

/// Keeps the vault key sealed by a key that never leaves the Android Keystore —
/// the phone's counterpart of Windows DPAPI. Every Flutter screen that opens
/// the vault (the app and the autofill picker) registers it.
object Keystore {
    private const val ALIAS = "keyhold-vault-key"

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, "keyhold/keystore")
            .setMethodCallHandler { call, result ->
                try {
                    val input = call.arguments as ByteArray
                    when (call.method) {
                        "protect" -> result.success(protect(input))
                        "unprotect" -> result.success(unprotect(input))
                        else -> result.notImplemented()
                    }
                } catch (e: Exception) {
                    result.error("keystore", e.message, null)
                }
            }
    }

    private fun key(): SecretKey {
        val store = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        (store.getKey(ALIAS, null) as? SecretKey)?.let { return it }
        val generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore")
        generator.init(
            KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .setKeySize(256)
                .build()
        )
        return generator.generateKey()
    }

    // Output: 12-byte IV followed by the ciphertext with its tag.
    private fun protect(plain: ByteArray): ByteArray {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.ENCRYPT_MODE, key())
        return cipher.iv + cipher.doFinal(plain)
    }

    private fun unprotect(sealed: ByteArray): ByteArray {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")
        cipher.init(Cipher.DECRYPT_MODE, key(), GCMParameterSpec(128, sealed.copyOfRange(0, 12)))
        return cipher.doFinal(sealed.copyOfRange(12, sealed.size))
    }
}
