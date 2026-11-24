package app.chudiptv.chud_iptv

import android.Manifest
import android.app.Activity
import android.app.PictureInPictureParams
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.provider.DocumentsContract
import android.util.Rational
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private var pendingFolder: MethodChannel.Result? = null
    private var device: MethodChannel? = null
    private var pipReady = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Flutter ne sait pas qu'il tourne sur un téléviseur : l'interface le lui demande au démarrage.
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "chud_iptv/device")
        device = channel
        PlaybackService.onStopRequested = { channel.invokeMethod("radioStopped", null) }
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "isTelevision" -> result.success(packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK))
                "openExternal" -> {
                    val view = Intent(Intent.ACTION_VIEW).apply {
                        setDataAndType(Uri.parse(call.argument<String>("url")), "video/*")
                        putExtra("title", call.argument<String>("title"))
                    }
                    try {
                        startActivity(Intent.createChooser(view, call.argument<String>("title")))
                        result.success(true)
                    } catch (e: android.content.ActivityNotFoundException) {
                        result.success(false)
                    }
                }
                "phoneFeatures" -> result.success(
                    mapOf(
                        "phone" to (
                            !packageManager.hasSystemFeature(PackageManager.FEATURE_LEANBACK) &&
                                resources.configuration.smallestScreenWidthDp < TABLET_WIDTH_DP
                            ),
                        "pip" to packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE),
                    ),
                )
                "setPipReady" -> {
                    pipReady = call.arguments as Boolean
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) setPictureInPictureParams(pipParams())
                    result.success(null)
                }
                "startRadio" -> try {
                    PlaybackService.start(this, call.argument("title")!!, call.argument("text")!!, call.argument("stop")!!)
                    result.success(true)
                } catch (e: IllegalStateException) {
                    // Refus d'Android, par exemple si l'app n'est plus à l'écran : la lecture s'arrêtera comme avant.
                    result.success(false)
                }
                "stopRadio" -> {
                    PlaybackService.stop(this)
                    result.success(null)
                }
                "askNotifications" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), ASK_NOTIFICATIONS)
                    }
                    result.success(null)
                }
                "pickFolder" -> pickFolder(result)
                "saveToFolder" -> saveToFolder(call.argument("folder")!!, call.argument("path")!!, call.argument("name")!!, result)
                "deleteDocument" -> {
                    try {
                        DocumentsContract.deleteDocument(contentResolver, Uri.parse(call.argument<String>("uri")))
                    } catch (e: Exception) {
                        // Déjà retiré, ou dossier devenu inaccessible : il n'y a plus rien à faire.
                    }
                    result.success(null)
                }
                "documentExists" -> result.success(documentExists(call.argument("uri")!!))
                else -> result.notImplemented()
            }
        }
    }

    private fun pipParams(): PictureInPictureParams {
        val builder = PictureInPictureParams.Builder().setAspectRatio(Rational(16, 9))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) builder.setAutoEnterEnabled(pipReady)
        return builder.build()
    }

    /// Avant Android 12, c'est à l'app d'ouvrir la petite fenêtre quand on la quitte.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (pipReady && Build.VERSION.SDK_INT < Build.VERSION_CODES.S) enterPictureInPictureMode(pipParams())
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        device?.invokeMethod("pipChanged", isInPictureInPictureMode)
    }

    /// Android n'ouvre un dossier que par son propre sélecteur, et l'accès doit être rendu durable.
    private fun pickFolder(result: MethodChannel.Result) {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).addFlags(
            Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        )
        try {
            pendingFolder = result
            startActivityForResult(intent, PICK_FOLDER)
        } catch (e: android.content.ActivityNotFoundException) {
            pendingFolder = null
            result.success(null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != PICK_FOLDER) return
        val uri = if (resultCode == Activity.RESULT_OK) data?.data else null
        if (uri != null) {
            contentResolver.takePersistableUriPermission(
                uri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
        }
        pendingFolder?.success(uri?.toString())
        pendingFolder = null
    }

    /// Un film pèse plusieurs Go : la copie part dans son propre fil.
    private fun saveToFolder(folder: String, path: String, name: String, result: MethodChannel.Result) {
        thread {
            var document: Uri? = null
            val saved = try {
                val tree = Uri.parse(folder)
                val parent = DocumentsContract.buildDocumentUriUsingTree(tree, DocumentsContract.getTreeDocumentId(tree))
                document = DocumentsContract.createDocument(contentResolver, parent, "application/octet-stream", name)
                contentResolver.openOutputStream(document!!)!!.use { output ->
                    File(path).inputStream().use { it.copyTo(output, 1 shl 20) }
                }
                document.toString()
            } catch (e: Exception) {
                document?.let { runCatching { DocumentsContract.deleteDocument(contentResolver, it) } }
                null
            }
            runOnUiThread { result.success(saved) }
        }
    }

    private fun documentExists(uri: String): Boolean = try {
        contentResolver.query(Uri.parse(uri), arrayOf(DocumentsContract.Document.COLUMN_DOCUMENT_ID), null, null, null)
            ?.use { it.moveToFirst() } ?: false
    } catch (e: Exception) {
        false
    }

    private companion object {
        const val PICK_FOLDER = 4201
        const val ASK_NOTIFICATIONS = 4202

        /// À partir de cette largeur, Android parle de tablette.
        const val TABLET_WIDTH_DP = 600
    }
}
