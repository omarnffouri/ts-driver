package com.transport_system.ts_driver.notification_managers


import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.IBinder
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.pusher.channels.call_channel.channel.CallChannel
import com.transport_system.ts_driver.pusher.manager.PusherManager
import com.transport_system.ts_driver.telecom.models.CallPayload

class OngoingCallNotificationService : Service() {


    companion object {

        private const val PAYLOAD_KEY = "callPayloadBundle"
        private const val IS_OUTGOING = "isOutgoing"
        private var isRunning = false

        // function start this service
        fun start(context: Context, callPayload: CallPayload, isOutgoing  :Boolean = false): Boolean {
            if (isRunning) {
                AppLogger.log("Ongoing call notification is already running in start service")
                return false
            }
            try {
                AppLogger.log("About to start a ongoing call notification service")
                val intent = Intent(context, OngoingCallNotificationService::class.java)
                intent.putExtra(PAYLOAD_KEY, callPayload.toBundle())
                intent.putExtra(IS_OUTGOING, isOutgoing)
                context.startService(intent)
                return true
            } catch (_: Exception) {
                return false
            }
        }

        // function to this service
        fun stop(context: Context): Boolean {
            if (!isRunning) {
                AppLogger.log("Ongoing call notification is not running in stop service")
                return false
            }
            try {
                AppLogger.log("About to stop a ongoing call notification service")
                val intent = Intent(context, OngoingCallNotificationService::class.java)
                context.stopService(intent)
                return true
            } catch (_: Exception) {
                return false
            }
        }
    }


    override fun onCreate() {
        super.onCreate()
        AppNotificationChannelManager().ensureAllChannels(context = applicationContext)

        // initializing pusher and call channel
        PusherManager.instance.initialize(context = applicationContext)
        CallChannel.instance.initialize(context = applicationContext)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        AppLogger.log("on start command success on ongoing call notification service")
        val extras: Bundle = intent?.getBundleExtra(PAYLOAD_KEY) ?: return START_NOT_STICKY
        val callPayload = CallPayload.fromBundle(extras)

        AppLogger.log("got a payload in intent of ongoing call notification service")


        val notification =
            AppNotificationManager(context = applicationContext).buildOngoingCallNotification(
                callPayload = callPayload,
                callTimeString = AgoraManager.instance.callViewModel.callState.value?.getName(),
                isOutGoing =  intent.getBooleanExtra(IS_OUTGOING, false)
            )
        startForeground(AppNotificationManager.ONGOING_CALL_NOTIFICATION_ID, notification)



        AppLogger.log("returning start sticky in ongoing call notification service")
        isRunning = true
        return START_STICKY
    }


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        AppNotificationManager(context = applicationContext).clearOngoingCallNotification()
        AppLogger.log("Ongoing call notification service destroyed successfully.")
    }
}
