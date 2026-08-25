package com.transport_system.ts_driver.helpers

import android.app.Service.VIBRATOR_SERVICE
import android.content.Context
import android.media.AudioAttributes
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class VibrationHelper(private val context: Context) {

    @Suppress("DEPRECATION")
    private val vibrator: Vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        val vibratorManager =
            context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
        vibratorManager.defaultVibrator
    } else {
        context.getSystemService(VIBRATOR_SERVICE) as Vibrator
    }

    private val vibrationPattern = longArrayOf(0, 2000, 500, 2000)

    fun startCallVibration() {
        try {
            if (!vibrator.hasVibrator()) {
                return
            }
            val vibrationEffect = VibrationEffect.createWaveform(vibrationPattern, 0)
            @Suppress("DEPRECATION")
            vibrator.vibrate(
                vibrationEffect, AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
            )
        } catch (e: Exception) {
            AppLogger.log("Exception while trying to make vibration for incoming call ===> ${e.message}")
        }
    }


    fun stopCallVibration() {
        try {
            vibrator.cancel()
        } catch (_: Exception) {
        }
    }
}