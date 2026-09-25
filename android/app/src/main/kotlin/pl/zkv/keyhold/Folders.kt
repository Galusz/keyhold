package pl.zkv.keyhold

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/// Backup folders on the phone: the user picks one in the system's own
/// folder window, and Keyhold keeps the right to write there. The copies'
/// names, ages and turns are decided in Dart; this only lists, moves, writes
/// and deletes files in that folder.
object Folders {
    private const val PICK = 7301
    private var picking: MethodChannel.Result? = null

    fun register(activity: Activity, engine: FlutterEngine) {
        val context = activity.applicationContext
        MethodChannel(engine.dartExecutor.binaryMessenger, "keyhold/folders").setMethodCallHandler { call, result ->
            try {
                if (call.method == "pick") {
                    picking = result
                    activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT_TREE), PICK)
                    return@setMethodCallHandler
                }
                val tree = Uri.parse(call.argument<String>("tree"))
                when (call.method) {
                    "files" -> result.success(files(context, tree).mapValues { it.value.modified })
                    "move" -> {
                        val all = files(context, tree)
                        val to = call.argument<String>("to")!!
                        all[to]?.let { DocumentsContract.deleteDocument(context.contentResolver, it.uri) }
                        DocumentsContract.renameDocument(context.contentResolver, all[call.argument<String>("from")!!]!!.uri, to)
                        result.success(null)
                    }
                    "write" -> {
                        val name = call.argument<String>("name")!!
                        val uri = files(context, tree)[name]?.uri
                            ?: DocumentsContract.createDocument(context.contentResolver, folder(tree), "application/octet-stream", name)!!
                        context.contentResolver.openOutputStream(uri, "wt")!!.use { it.write(call.argument<ByteArray>("bytes")!!) }
                        result.success(null)
                    }
                    "delete" -> {
                        files(context, tree)[call.argument<String>("name")!!]?.let {
                            DocumentsContract.deleteDocument(context.contentResolver, it.uri)
                        }
                        result.success(null)
                    }
                    "release" -> {
                        context.contentResolver.releasePersistableUriPermission(
                            tree, Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
                        )
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("folder", e.message, null)
            }
        }
    }

    /// The folder the user picked: kept for good, so copies go there after a restart too.
    fun onResult(context: Context, requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != PICK) return false
        val result = picking ?: return true
        picking = null
        val tree = data?.data
        if (resultCode != Activity.RESULT_OK || tree == null) {
            result.success(null)
            return true
        }
        context.contentResolver.takePersistableUriPermission(
            tree, Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
        )
        result.success(tree.toString())
        return true
    }

    private class Entry(val uri: Uri, val modified: Long?)

    private fun folder(tree: Uri): Uri =
        DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))

    private fun files(context: Context, tree: Uri): Map<String, Entry> {
        val children = DocumentsContract.buildChildDocumentsUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
        val columns = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
        )
        val out = mutableMapOf<String, Entry>()
        context.contentResolver.query(children, columns, null, null, null)?.use { c ->
            while (c.moveToNext()) {
                if (c.getString(3) == DocumentsContract.Document.MIME_TYPE_DIR) continue
                val modified = if (c.isNull(2)) null else c.getLong(2)
                out[c.getString(1)] = Entry(DocumentsContract.buildDocumentUriUsingTree(tree, c.getString(0)), modified)
            }
        }
        return out
    }
}
