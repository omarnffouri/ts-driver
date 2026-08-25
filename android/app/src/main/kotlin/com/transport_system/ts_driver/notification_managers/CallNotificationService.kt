package com.transport_system.ts_driver.notification_managers


import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.IBinder
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.helpers.RingtoneHelper
import com.transport_system.ts_driver.helpers.VibrationHelper
import com.transport_system.ts_driver.pusher.channels.call_channel.channel.CallChannel
import com.transport_system.ts_driver.pusher.manager.PusherManager
import com.transport_system.ts_driver.telecom.models.CallPayload

class CallNotificationService : Service() {

    private lateinit var vibrationHelper : VibrationHelper

    companion object {

        private const val PAYLOAD_KEY = "callPayloadBundle"
        private var isRunning = false

        // function start this service
        fun start(context: Context, callPayload: CallPayload): Boolean {
            if (isRunning) {
                AppLogger.log("Call notification is already running in start service")
                return false
            }
            try {
                AppLogger.log("About to start a call notification service")
                val intent = Intent(context, CallNotificationService::class.java)
                intent.putExtra(PAYLOAD_KEY, callPayload.toBundle())
                context.startService(intent)
                return true
            } catch (_: Exception) {
                return false
            }
        }

        // function to this service
        fun stop(context: Context): Boolean {
            if (!isRunning) {
                AppLogger.log("Call notification is not running in stop service")
                return false
            }
            try {
                AppLogger.log("About to stop a call notification service")
                val intent = Intent(context, CallNotificationService::class.java)
                context.stopService(intent)
                return true
            } catch (_: Exception) {
                return false
            }
        }
    }


    override fun onCreate() {
        super.onCreate()
        vibrationHelper = VibrationHelper(context = applicationContext)
        AppNotificationChannelManager().ensureAllChannels(context = applicationContext)

        // initializing pusher and call channel
        PusherManager.instance.initialize(context = applicationContext)
        CallChannel.instance.initialize(context = applicationContext)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        AppLogger.log("on start command success")
        val extras: Bundle = intent?.getBundleExtra(PAYLOAD_KEY) ?: return START_NOT_STICKY
        val callPayload = CallPayload.fromBundle(extras)

        AppLogger.log("got a payload in intent")

        // Play default ringtone and vibration for incoming call
        RingtoneHelper.playRingtone(context = applicationContext)
        vibrationHelper.startCallVibration()



        // Create and show the notification
        val notification =
            AppNotificationManager(context = applicationContext).buildIncommingCallNotification(
                callPayload = callPayload
            )
        startForeground(AppNotificationManager.INCOMMING_CALL_NOTIFICATION_ID, notification)



        //
        // sending call ringing broadcast
        applicationContext.sendBroadcast(
            CallBroadcastReceiver.buildBroadcastIntent(
                context = applicationContext,
                CallBroadcastActions.ACTION_CALL_INCOMING_RINGING,
                data = callPayload.toBundle()
            )
        )

        AppLogger.log("returning start sticky")
        isRunning = true
        return START_STICKY
    }


    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        isRunning = false
        // stop ringtone and clear notification
        RingtoneHelper.stopRingtone()
        AppNotificationManager(context = applicationContext).clearIncommingCallNotification()
        vibrationHelper.stopCallVibration()
        AppLogger.log("Call notification service destroyed successfully.")
    }
}
