package com.period.period_tracker

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * 备份目录采用 Android 存储访问框架（SAF，ACTION_OPEN_DOCUMENT_TREE）：
 * - 用户在系统目录选择器中指定目录并授权（系统会弹出"允许访问？"确认框）；
 * - 通过 takePersistableUriPermission 持久化授权，重启 / 升级后依然有效；
 * - 写文件走 ContentResolver + DocumentsContract，分区存储下无需任何存储权限。
 */
class MainActivity : FlutterActivity() {

    private val channelName = "com.period.period_tracker/backup"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pickDirectory" -> {
                        if (pendingResult != null) {
                            result.error("BUSY", "目录选择器已打开", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        try {
                            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                                flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
                            }
                            @Suppress("DEPRECATION")
                            startActivityForResult(intent, REQUEST_OPEN_TREE)
                        } catch (e: Exception) {
                            pendingResult = null
                            result.error("LAUNCH_FAILED", e.message, null)
                        }
                    }

                    "hasPermission" -> {
                        val uri = Uri.parse(call.argument<String>("uri"))
                        result.success(isPersisted(uri))
                    }

                    "writeFile" -> {
                        try {
                            val treeUri = Uri.parse(call.argument<String>("treeUri"))
                            val fileName = call.argument<String>("fileName")
                                ?: throw IllegalArgumentException("缺少 fileName")
                            val content = call.argument<String>("content")
                                ?: throw IllegalArgumentException("缺少 content")
                            if (!isPersisted(treeUri)) {
                                result.error(
                                    "PERMISSION_DENIED",
                                    "目录授权已失效，请重新选择备份目录",
                                    null,
                                )
                                return@setMethodCallHandler
                            }
                            val docUri = findOrCreateFile(treeUri, fileName)
                            contentResolver.openOutputStream(docUri, "wt")?.use { os ->
                                os.write(content.toByteArray(Charsets.UTF_8))
                            } ?: throw IllegalStateException("无法打开输出流")
                            result.success("${treeDisplayPath(treeUri)}/$fileName")
                        } catch (e: Exception) {
                            result.error("WRITE_FAILED", e.message ?: "写入失败", null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        @Suppress("DEPRECATION")
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_OPEN_TREE) return
        val result = pendingResult
        pendingResult = null
        if (result == null) return
        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result.success(null) // 用户取消
            return
        }
        val uri = data.data!!
        try {
            val flags = (data.flags and
                (Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
                .let {
                    if (it == 0) {
                        Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    } else {
                        it
                    }
                }
            contentResolver.takePersistableUriPermission(uri, flags)
            result.success(
                mapOf(
                    "uri" to uri.toString(),
                    "path" to treeDisplayPath(uri),
                ),
            )
        } catch (e: Exception) {
            result.error("PERMISSION_DENIED", e.message ?: "授权失败", null)
        }
    }

    private fun isPersisted(uri: Uri): Boolean =
        contentResolver.persistedUriPermissions.any {
            it.uri == uri && it.isWritePermission
        }

    /// 在树目录中查找同名文件，存在则复用（覆盖写），不存在则新建。
    private fun findOrCreateFile(treeUri: Uri, fileName: String): Uri {
        val treeDocId = DocumentsContract.getTreeDocumentId(treeUri)
        val parentDocUri =
            DocumentsContract.buildDocumentUriUsingTree(treeUri, treeDocId)
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, treeDocId)
        contentResolver.query(
            childrenUri,
            arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            ),
            null,
            null,
            null,
        )?.use { c ->
            while (c.moveToNext()) {
                val name = c.getString(1)
                if (name == fileName) {
                    val docId = c.getString(0)
                    return DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                }
            }
        }
        return DocumentsContract.createDocument(
            contentResolver,
            parentDocUri,
            "application/json",
            fileName,
        ) ?: throw IllegalStateException("无法在所选目录创建文件")
    }

    /// 把 content tree URI 转成用户可读的路径用于界面展示。
    /// 例如 primary:Backup → /storage/emulated/0/Backup
    private fun treeDisplayPath(uri: Uri): String {
        val docId = try {
            DocumentsContract.getTreeDocumentId(uri)
        } catch (_: Exception) {
            return uri.toString()
        }
        val parts = docId.split(":", limit = 2)
        val volume = parts.getOrNull(0).orEmpty()
        val sub = parts.getOrNull(1).orEmpty()
        return when (volume) {
            "primary" -> "/storage/emulated/0/${sub.trimEnd('/')}"
            else -> "/storage/$volume/${sub.trimEnd('/')}"
        }.trimEnd('/')
    }

    companion object {
        private const val REQUEST_OPEN_TREE = 4201
    }
}
