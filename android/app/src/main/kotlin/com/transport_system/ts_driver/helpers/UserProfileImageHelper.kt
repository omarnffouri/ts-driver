package com.transport_system.ts_driver.helpers

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.BitmapShader
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.Shader
import android.net.Uri
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.security.MessageDigest

object UserProfileImageHelper {

    private const val PROFILE_IMAGE_CACHE_DIR_NAME = "profile_images"


    //
    // function to save image bitmap against url in cache folder
    fun cacheUserImage(context: Context, url: String, bitmap: Bitmap) {
        try {
            val profileImageDir = getProfileImageDir(context = context)
            if (!profileImageDir.exists()) {
                profileImageDir.mkdirs()
            }
            val file = File(profileImageDir, hashString(url) + ".png")
            FileOutputStream(file).use { fos ->
                getCircularBitmap(bitmap = resizeBitmapIfNeeded(bitmap)).compress(
                    Bitmap.CompressFormat.PNG,
                    30,
                    fos
                )
            }
        } catch (e: IOException) {
            e.printStackTrace()
        }
    }

    //
    // function to get user image cached against url
    fun getUserImage(context: Context, url : String) : Uri? {
        try{
            val cachedImage = getCachedImage(context = context, url = url)
            if(cachedImage != null){
                return cachedImage
            }
            PicassoHelper.cacheUserImageFromUrl(context = context, url = url)
            return null
        }
        catch (_:Exception){
            return null
        }
    }

    private fun getCachedImage(context: Context, url: String): Uri? {
        try {
            val profileImageDir = getProfileImageDir(context = context)
            if (!profileImageDir.exists()) {
                profileImageDir.mkdirs()
            }
            val fileName = hashString(url) + ".png"
            val file = File(profileImageDir, fileName)
            if (file.exists()) {
                return Uri.fromFile(file)
            }
            return null
        } catch (e: IOException) {
            return null
        }
    }

    fun clearCache(context: Context) {
        val profileImageDir = getProfileImageDir(context = context)
        if (profileImageDir.exists()) {
            profileImageDir.deleteRecursively()
        }
    }

    private fun getProfileImageDir(context: Context): File {
        return File(context.cacheDir, PROFILE_IMAGE_CACHE_DIR_NAME)
    }

    private fun hashString(input: String): String {
        val bytes = MessageDigest.getInstance("SHA-256").digest(input.toByteArray())
        return bytes.joinToString("") { "%02x".format(it) }
    }

    private fun getCircularBitmap(bitmap: Bitmap): Bitmap {
        try {
            if (bitmap.isRecycled) {
                return bitmap
            }
            val size = bitmap.width.coerceAtMost(bitmap.height)
            val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            val paint = Paint()
            paint.shader = BitmapShader(bitmap, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
            paint.isAntiAlias = true
            val rectF = RectF(0f, 0f, size.toFloat(), size.toFloat())
            canvas.drawOval(rectF, paint)
            return output
        } catch (e: Exception) {
            e.printStackTrace()
            return bitmap
        }
    }

    private fun resizeBitmapIfNeeded(bitmap: Bitmap): Bitmap {
        val maxWidth = 800
        val maxHeight = 800
        val targetSizeMin = 500 * 1024  // 500 KB in bytes
        val targetSizeMax = 700 * 1024  // 700 KB in bytes

        // Check image resolution
        if (bitmap.width > 500 || bitmap.height > 500) {
            // Resize based on the aspect ratio
            val aspectRatio = bitmap.height.toFloat() / bitmap.width.toFloat()
            val newWidth = if (bitmap.width > bitmap.height) maxWidth else (maxHeight / aspectRatio).toInt()
            val newHeight = if (bitmap.height > bitmap.width) maxHeight else (maxWidth * aspectRatio).toInt()

            // Create the resized bitmap
            val resizedBitmap = Bitmap.createScaledBitmap(bitmap, newWidth, newHeight, false)

            // Compress and check the file size
            val byteArrayOutputStream = ByteArrayOutputStream()
            var quality = 100

            // Loop to reduce quality until the file size is in the desired range
            while (true) {
                byteArrayOutputStream.reset()
                resizedBitmap.compress(Bitmap.CompressFormat.PNG, quality, byteArrayOutputStream)
                val byteArray = byteArrayOutputStream.toByteArray()

                val fileSize = byteArray.size
                if (fileSize in targetSizeMin..targetSizeMax || quality <= 10) {
                    break
                }

                // Reduce the quality to try to fit in the target size range
                quality -= 5
            }

            // Return the resized bitmap
            return BitmapFactory.decodeByteArray(byteArrayOutputStream.toByteArray(), 0, byteArrayOutputStream.size())
        } else {
            return bitmap
        }
    }
}
