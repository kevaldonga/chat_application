package com.example.chatty

import android.content.Intent
import android.net.Uri
import android.provider.MediaStore
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    lateinit var listener: (String) -> Unit

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == channelFilePicker.REQUEST_CODE_SINGLE && resultCode == RESULT_OK) {
            val fileUri = data?.data
            fileUri?.path ?: return
            listener.invoke(UriUtils.getPathFromUri(context, fileUri)!!)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // toast
        toastChannel()

        // call and open file
        callandFileChannel()

        // filepicker signal receiver
        filePickerSignalReceiver()

        // to handle paths
        pathhandler()
    }

    private fun filePickerSignalReceiver() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channelFilePicker.CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "filepicker") {
                        // pick single file
                        var intent = Intent(Intent.ACTION_PICK)
                        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
                        // set type to following to accept all kids of files
                        intent.type = "*/*"
                        intent = Intent.createChooser(intent, "Pick a File")
                        listener = { path -> result.success(path) }
                        super.startActivityForResult(intent, channelFilePicker.REQUEST_CODE_SINGLE)
                    } else if (call.method == "imagepicker") {
                        // pick single image
                        var intent =
                                Intent(
                                        Intent.ACTION_PICK,
                                        MediaStore.Images.Media.EXTERNAL_CONTENT_URI
                                )
                        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
                        if (intent.resolveActivity(packageManager) != null) {
                            listener = { path -> result.success(path) }
                            super.startActivityForResult(
                                    intent,
                                    channelFilePicker.REQUEST_CODE_SINGLE
                            )
                        } else {
                            Toast.makeText(
                                            context,
                                            "you don't have gallery installed !",
                                            Toast.LENGTH_SHORT
                                    )
                                    .show()
                        }
                    }
                }
    }

    private fun callandFileChannel() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channelIntent.CHANNEL)
                .setMethodCallHandler { call, _ ->
                    // handle calling
                    if (call.method == "call") {
                        val phoneno = call.argument<String>("call")
                        val intent = Intent(Intent.ACTION_CALL)
                        intent.data = Uri.parse("tel:${phoneno}")
                        startActivity(intent)
                    } else if (call.method == channelIntent.OPEN_FILE) {
                        val filepath = call.argument<String>(channelIntent.OPEN_FILE_KEY)
                        if (filepath != null) {
                            channelIntent.openfile(filepath, applicationContext)
                        }
                    }
                }
    }

    private fun toastChannel() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, toast.CHANNEL)
                .setMethodCallHandler { call, _ ->
                    if (call.method == toast.METHOD_TOAST) {
                        val message = call.argument<String>(toast.KEY_MESSAGE)
                        Toast.makeText(this@MainActivity, message, Toast.LENGTH_SHORT).show()
                    }
                }
    }

    private fun pathhandler() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channelpath.CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == channelpath.DOCUMENT) {
                        result.success(context.filesDir.absolutePath)
                    } else if (call.method == channelpath.TEMP) {
                        result.success(context.cacheDir.absolutePath)
                    } else if (call.method == channelpath.MEDIA) {
                        val appMediaDir =
                                context.getExternalFilesDir(context.getPackageName() + "/media")
                                        ?.getAbsolutePath()
                        result.success(appMediaDir)
                    }
                }
    }
}
