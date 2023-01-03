package com.example.chatty

import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat.startActivity
import androidx.core.content.FileProvider
import java.io.File

class channelIntent {
        companion object{
            const val OPEN_FILE = "openfile"
            const val CHANNEL = "flutter.io/intent";
            const val OPEN_FILE_KEY = "path"
            fun openfile(url: String,context: Context) {
                    val file = File(url);
                    val uri = FileProvider.getUriForFile(context, context.applicationContext.packageName + ".provider", file)
                    val intent = Intent(Intent.ACTION_VIEW)
                    if (url.endsWith(".doc") || url.endsWith(".docx")) {
                        // Word document
                        intent.setDataAndType(uri, "application/msword")
                    } else if (url.endsWith(".pdf")) {
                        // PDF file
                        intent.setDataAndType(uri, "application/pdf")
                    } else if (url.endsWith(".ppt") || url.endsWith(".pptx")) {
                        // Powerpoint file
                        intent.setDataAndType(uri, "application/vnd.ms-powerpoint")
                    } else if (url.endsWith(".xls") || url.endsWith(".xlsx")) {
                        // Excel file
                        intent.setDataAndType(uri, "application/vnd.ms-excel")
                    } else if (url.endsWith(".zip") || url.endsWith(".rar")) {
                        // WAV audio file
                        intent.setDataAndType(uri, "application/x-wav")
                    } else if (url.endsWith(".rtf")) {
                        // RTF file
                        intent.setDataAndType(uri, "application/rtf")
                    } else if (url.endsWith(".wav") || url.endsWith(".mp3")) {
                        // WAV audio file
                        intent.setDataAndType(uri, "audio/x-wav")
                    } else if (url.endsWith(".gif")) {
                        // GIF file
                        intent.setDataAndType(uri, "image/gif")
                    } else if (url.endsWith(".jpg") || url.endsWith(".jpeg") || url.endsWith(".png")) {
                        // JPG file
                        intent.setDataAndType(uri, "image/jpeg")
                    } else if (url.endsWith(".txt")) {
                        // Text file
                        intent.setDataAndType(uri, "text/plain")
                    } else if (url.endsWith(".3gp") || url.endsWith(".mpg") || url.endsWith(".mpeg") || url.endsWith(".mpe") || url.endsWith(".mp4") || url.endsWith(".avi")) {
                        // Video files
                        intent.setDataAndType(uri, "video/*")
                    } else if(url.endsWith(".apk")){
                        // application files
                        intent.setDataAndType(uri,"application/vnd.android.package-archive");
                    }
                    else {
                        // Other files
                        intent.setDataAndType(uri, "*/*")
                    }
                    intent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    context.startActivity(intent)
            }
        }
}