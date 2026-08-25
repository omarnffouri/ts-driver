package com.transport_system.ts_driver.notification_managers

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.RingtoneManager
import android.provider.Settings

class AppNotificationChannelManager {

    companion object {
        const val INCOMING_CALL_CHANNEL_ID = "incoming_calls_channel"
        const val INCOMING_CALL_CHANNEL_NAME = "Incoming Calls"
        const val MISSED_CALL_CHANNEL_ID = "missed_calls_channel"
        const val MISSED_CALL_CHANNEL_NAME = "Missed Calls"
        const val ONGOING_CALL_CHANNEL_ID = "ongoing_calls_channel"
        const val ONGOING_CALL_CHANNEL_NAME = "Ongoing Calls"
        const val CHANNEL_IMPORTANCE = NotificationManager.IMPORTANCE_HIGH
    }

    fun ensureAllChannels(context: Context): Boolean {
        return ensureIncomingCallNotificationChannel(context) &&
                ensureMissedCallNotificationChannel(context) &&
                ensureOngoingCallNotificationChannel(context)
    }

    // Function to ensure the incoming call notification channel is created and enabled
    fun ensureIncomingCallNotificationChannel(
        context: Context
    ): Boolean {
        // Create channel if not exists
        createChannelIfNotExists(
            context = context,
            channelName = INCOMING_CALL_CHANNEL_NAME,
            channelId = INCOMING_CALL_CHANNEL_ID
        )

        // Check if channel is enabled
        return isChannelEnabled(context = context, channelId = INCOMING_CALL_CHANNEL_ID)
    }


    // Function to ensure the incoming call notification channel is created and enabled
    fun ensureMissedCallNotificationChannel(
        context: Context
    ): Boolean {
        // Create channel if not exists
        createChannelIfNotExists(
            context = context,
            channelName = MISSED_CALL_CHANNEL_NAME,
            channelId = MISSED_CALL_CHANNEL_ID
        )

        // Check if channel is enabled
        return isChannelEnabled(context = context, channelId = MISSED_CALL_CHANNEL_ID)
    }


    fun ensureOngoingCallNotificationChannel(
        context: Context
    ): Boolean {
        // Create channel if not exists
        createChannelIfNotExists(
            context = context,
            channelName = ONGOING_CALL_CHANNEL_NAME,
            channelId = ONGOING_CALL_CHANNEL_ID
        )

        // Check if channel is enabled
        return isChannelEnabled(context = context, channelId = ONGOING_CALL_CHANNEL_ID)
    }


    private fun createChannelIfNotExists(context: Context, channelName: String, channelId: String) {
        if (!channelExists(context = context, channelId = channelId)) {
            val channel = NotificationChannel(channelId, channelName, CHANNEL_IMPORTANCE).apply {
                if (channelId != INCOMING_CALL_CHANNEL_ID) {
                    setSound(
                        RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION),
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build()
                    )
                    enableVibration(true)
                } else {
                    enableVibration(false)
                    setSound(null, null)
                }
                enableLights(true)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
            }
            getNotificationManager(context).createNotificationChannel(channel)
        }
    }

    // Checks if the notification channel already exists
    private fun channelExists(context: Context, channelId: String): Boolean {
        val notificationManager = getNotificationManager(context)
        return notificationManager.getNotificationChannel(channelId) != null
    }

    // Checks if the channel is enabled; if not, opens the settings to enable it
    private fun isChannelEnabled(context: Context, channelId: String): Boolean {
        val notificationManager = getNotificationManager(context)
        val channel = notificationManager.getNotificationChannel(channelId)

        if (channel != null && channel.importance == NotificationManager.IMPORTANCE_NONE) {
            val intent = Intent(Settings.ACTION_CHANNEL_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, context.packageName)
                putExtra(Settings.EXTRA_CHANNEL_ID, channelId)
            }
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
            return false
        }
        return true
    }


    // Retrieves the NotificationManager instance
    private fun getNotificationManager(context: Context): NotificationManager {
        return context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    }
}
