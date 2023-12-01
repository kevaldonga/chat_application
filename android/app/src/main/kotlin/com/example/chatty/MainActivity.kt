package com.example.chatty

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.ContactsContract
import android.provider.MediaStore
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    lateinit var listener: (String) -> Unit
    val CONTACT_REQUEST_CODE = 201

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == channelFilePicker.REQUEST_CODE_SINGLE && resultCode == RESULT_OK) {
            val fileUri = data?.data
            fileUri?.path ?: return
            var uriutils = UriUtils()
            listener.invoke(uriutils.getPath(fileUri, context)!!)
        }
        if (requestCode == CONTACT_REQUEST_CODE) {
            if (resultCode == RESULT_OK) {
                Toast.makeText(context, "contact added successfully !", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(context, "contact added canceled !", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // create notification channel
        initNotificationChannel();

        // create a toast message
        toastChannel()

        // call and open file
        callandFileChannel()

        // file picker signal receiver
        filePickerSignalReceiver()

        // to handle paths
        pathhandler()
    }

    private fun initNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = getString(R.string.channel_name)
            val descriptionText = getString(R.string.channel_description)
            val importance = NotificationManager.IMPORTANCE_HIGH
            val mChannel = NotificationChannel(getString(R.string.channel_id), name, importance)
            mChannel.description = descriptionText
            // Register the channel with the system. You can't change the importance
            // or other notification behaviors after this.
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(mChannel)
        }
    }

    private fun filePickerSignalReceiver() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channelFilePicker.CHANNEL)
                .setMethodCallHandler { call, result ->
                    if (call.method == "filepicker") {
                        // pick single file
                        var intent = Intent(Intent.ACTION_PICK)
                        intent.type = "*/*"
                        // set type to following to accept all kids of files
                        intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, false)
                        listener = { path -> result.success(path) }
                        if (intent.resolveActivity(packageManager) != null) {
                            super.startActivityForResult(
                                    intent,
                                    channelFilePicker.REQUEST_CODE_SINGLE
                            )
                        }
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
                    } else if (call.method == channelIntent.ADD_CONTACT) {
                        val intent = Intent(ContactsContract.Intents.Insert.ACTION)
                        intent.type = ContactsContract.RawContacts.CONTENT_TYPE
                        intent.putExtra(
                                ContactsContract.Intents.Insert.NAME,
                                call.argument<String>("name")
                        )
                        intent.putExtra(
                                ContactsContract.Intents.Insert.PHONE,
                                call.argument<String>("phoneno")
                        )
                        intent.putExtra(
                                ContactsContract.Intents.Insert.EMAIL,
                                call.argument<String>("email")
                        )
                        startActivity(intent)
                    }
                }
    }

    private fun toastChannel() {
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, toast.CHANNEL)
                .setMethodCallHandler { call, _ ->
                    if (call.method == toast.METHOD_TOAST) {
                        val message = call.argument<String>(toast.KEY_MESSAGE)
                        Toast.makeText(context, message, Toast.LENGTH_SHORT).show();
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
                                "${Environment.getExternalStorageDirectory()}/Android/media/${context.packageName}"
                        result.success(appMediaDir)
                    }
                }
    }
}
