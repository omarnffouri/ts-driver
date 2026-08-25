package com.transport_system.ts_driver.notification_managers

import android.Manifest
import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.pm.PackageManager
import android.graphics.BitmapFactory
import android.graphics.Color
import android.media.RingtoneManager
import android.os.Bundle
import android.widget.RemoteViews
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.Person
import androidx.core.graphics.drawable.IconCompat
import com.transport_system.ts_driver.R
import com.transport_system.ts_driver.activities.CallActivity
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.helpers.UserProfileImageHelper
import com.transport_system.ts_driver.telecom.models.CallPayload


class AppNotificationManager(private val context: Context) {


    companion object {
        const val INCOMMING_CALL_NOTIFICATION_ID = 8495
        const val ONGOING_CALL_NOTIFICATION_ID = 5698
        const val MISSED_CALL_NOTIFICATION_ID = 8965
    }


    fun buildIncommingCallNotification(callPayload: CallPayload): Notification {
        AppNotificationChannelManager().ensureIncomingCallNotificationChannel(context = context)
        return NotificationCompat.Builder(context, AppNotificationChannelManager.INCOMING_CALL_CHANNEL_ID).apply {
            //
            // setting notification configs
            setAutoCancel(false)
            setChannelId(AppNotificationChannelManager.INCOMING_CALL_CHANNEL_ID)
            setCategory(NotificationCompat.CATEGORY_CALL)
            priority = NotificationCompat.PRIORITY_MAX
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            setOngoing(true)
            setWhen(0)
            setTimeoutAfter(30000)
            setOnlyAlertOnce(true)
            setSound(null)
            setVibrate(null)



            //
            // setting full screen and content and delete PI
            setFullScreenIntent(
                getActivityPendingIntent(callPayload.toBundle()), true
            )
            setContentIntent(
                getActivityPendingIntent(callPayload.toBundle())
            )
            setDeleteIntent(
                buildCallBroadcastPI(
                    action = CallBroadcastActions.ACTION_CALL_INCOMING_TIMEOUT,
                    data = callPayload.toBundle()
                )
            )

            //
            // loading small icon and color
            setSmallIcon(if (callPayload.isVideoCall()) R.drawable.ic_video else R.drawable.ic_accept)
            try {
                color = Color.parseColor("#4CAF50")
            } catch (_: Exception) {
            }


            // person of incoming call
            val person = Person.Builder()
                .setName(callPayload.callerName)
                .setKey(callPayload.callerName)
                .setBot(false)
                .setImportant(true)

            //
            // setting user image if exist
            if(callPayload.callerImage?.isNotEmpty() == true){
                try{
                    val uri = UserProfileImageHelper.getUserImage(context = context, url = callPayload.callerImage!!)
                   if(uri != null){
                       person.setIcon(
                           IconCompat.createWithBitmap(
                               BitmapFactory.decodeStream(
                                   context.contentResolver.openInputStream(uri)
                               )
                           )
                       )
                   }
                }
                catch (_:Exception){}
            }

            //
            // setting style of notification
            setStyle(
                NotificationCompat.CallStyle.forIncomingCall(
                    person.build(), buildCallBroadcastPI(
                        action = CallBroadcastActions.ACTION_CALL_INCOMING_DECLINE,
                        data = callPayload.toBundle()
                    ), buildCallBroadcastPI(
                        action = CallBroadcastActions.ACTION_CALL_INCOMING_ACCEPT,
                        data = callPayload.toBundle()
                    )
                )
            )
        }.build()
    }

    fun clearIncommingCallNotification() {
        getNotificationManager().cancel(INCOMMING_CALL_NOTIFICATION_ID)
    }

    fun clearOngoingCallNotification() {
        getNotificationManager().cancel(ONGOING_CALL_NOTIFICATION_ID)
    }

    fun showMiscallNotification(callPayload: CallPayload) {
        AppNotificationChannelManager().ensureMissedCallNotificationChannel(context = context)
        AppLogger.log("after ensuring miscall notification channel")
        val notification = NotificationCompat.Builder(context, AppNotificationChannelManager.MISSED_CALL_CHANNEL_ID).apply {
            //
            // setting notification configs
            setSound(RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION))
            setChannelId(AppNotificationChannelManager.MISSED_CALL_CHANNEL_ID)
            setAutoCancel(false)
            setDefaults(NotificationCompat.DEFAULT_VIBRATE)
            setCategory(NotificationCompat.CATEGORY_MISSED_CALL)
            priority = NotificationCompat.PRIORITY_MAX
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            setOngoing(false)
            setWhen(0)
            setOnlyAlertOnce(true)
            AppLogger.log("after applying notification configs")
            //
            // loading small icon and color
            setSmallIcon(if (callPayload.isVideoCall()) R.drawable.ic_video_missed else R.drawable.ic_call_missed)
            try {
                color = Color.parseColor("#4CAF50")
            } catch (_: Exception) {
            }
            AppLogger.log("after setting notification small icon")

            //
            // initializing and setting remote view
            val remoteViews = RemoteViews(context.packageName, R.layout.layout_custom_miss_notification)
            remoteViews.setTextViewText(
                R.id.tvNameCaller,
                callPayload.callerName ?: ""
            )
            remoteViews.setTextViewText(
                R.id.tvNumber,
                "You missed ${if (callPayload.isVideoCall()) "video" else "audio"} call"
            )

            AppLogger.log("after loading views")


            //
            // setting user image
            val imageUrl = callPayload.callerImage
            if (!imageUrl.isNullOrEmpty()) {
                try {
                    val uri = UserProfileImageHelper.getUserImage(context = context, url = imageUrl)
                    if(uri != null){
                        remoteViews.setImageViewBitmap(R.id.ivAvatar,BitmapFactory.decodeStream(
                            context.contentResolver.openInputStream(uri)
                        ))
                    }
                }
                catch (_:Exception){ }
            }

            AppLogger.log("after loading image")

            // setting notification views
            setStyle(NotificationCompat.DecoratedCustomViewStyle())
            setCustomContentView(remoteViews)
            setCustomBigContentView(remoteViews)

            AppLogger.log("after setting views in notification")
        }.build()
        AppLogger.log("after building notification")
        //
        // setting notification flag and present notification
        notification.flags = Notification.FLAG_ONLY_ALERT_ONCE
        if (ActivityCompat.checkSelfPermission(
                context,
                Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            AppLogger.log("no permission to post the miscall notification")
            return
        }
        AppLogger.log("after ensuring notification permission")
        getNotificationManager().notify(MISSED_CALL_NOTIFICATION_ID, notification)
        AppLogger.log("notify for the miscall called successfully")
    }

    fun buildOngoingCallNotification(callPayload: CallPayload, callTimeString : String? = null, isOutGoing : Boolean): Notification {
        AppNotificationChannelManager().ensureOngoingCallNotificationChannel(context = context)
        return NotificationCompat.Builder(context, AppNotificationChannelManager.ONGOING_CALL_CHANNEL_ID).apply {
            //
            // setting notification configs
            setAutoCancel(false)
            setChannelId(AppNotificationChannelManager.ONGOING_CALL_CHANNEL_ID)
            setCategory(NotificationCompat.CATEGORY_CALL)
            priority = NotificationCompat.PRIORITY_MAX
            setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            setOngoing(true)
            setWhen(0)
            setOnlyAlertOnce(true)
            setSound(null)
            setVibrate(null)



            setFullScreenIntent(
                getOngoingCallActivityPendingIntent(callPayload.toBundle()), true
            )
            setContentIntent(
                getOngoingCallActivityPendingIntent(callPayload.toBundle())
            )


            setSmallIcon(if (callPayload.isVideoCall()) R.drawable.ic_video else R.drawable.ic_accept)
            try {
                color = Color.parseColor("#4CAF50")
            } catch (_: Exception) {
            }


            val person = Person.Builder()
                .setName(if(isOutGoing) callPayload.receiverName else callPayload.callerName)
                .setKey(if(isOutGoing) callPayload.receiverName else callPayload.callerName)
                .setBot(false)
                .setImportant(true)

            val image = if(isOutGoing) callPayload.receiverImage else callPayload.callerImage

            if(image?.isNotEmpty() == true){
                try{
                    val uri = UserProfileImageHelper.getUserImage(context = context, url = image)
                    if(uri != null){
                        person.setIcon(
                            IconCompat.createWithBitmap(
                                BitmapFactory.decodeStream(
                                    context.contentResolver.openInputStream(uri)
                                )
                            )
                        )
                    }
                }
                catch (_:Exception){}
            }


            setStyle(NotificationCompat.CallStyle.forOngoingCall(
                person.build(),
                buildCallBroadcastPI(
                    action = CallBroadcastActions.ACTION_CALL_ENDED,
                    data = callPayload.toBundle()
                )
            ))

            if(callTimeString != null){
                setContentText(callTimeString)
            }


        }.build()
    }

    private fun buildCallBroadcastPI(action: CallBroadcastActions, data: Bundle): PendingIntent {
        val broadcastIntent = CallBroadcastReceiver.buildBroadcastIntent(
            context = context,
            action = action,
            data = data
        )
        return PendingIntent.getBroadcast(
            context,
            2244,
            broadcastIntent,
            getPendingIntentFlags()
        )
    }

    private fun getPendingIntentFlags(): Int {
        return PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    }

    private fun getActivityPendingIntent(data: Bundle): PendingIntent {
        val intent = CallActivity.getIntent(context, data, forIncomingCallNotification = true, fromCallAccept = false)
        return PendingIntent.getActivity(context, 2243, intent, getPendingIntentFlags())
    }

    private fun getOngoingCallActivityPendingIntent(data: Bundle): PendingIntent {
        val intent = CallActivity.getIntent(context, data, forIncomingCallNotification = false, fromCallAccept = true)
        return PendingIntent.getActivity(context, 2243, intent, getPendingIntentFlags())
    }

     fun getNotificationManager(): NotificationManagerCompat {
        return NotificationManagerCompat.from(context)
    }

}