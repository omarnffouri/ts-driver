package com.transport_system.ts_driver.firebase_messaging

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.util.Log
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.helpers.CallEventHelper
import com.transport_system.ts_driver.notification_managers.AppNotificationManager
import com.transport_system.ts_driver.telecom.managers.CallManager
import com.transport_system.ts_driver.telecom.models.CallPayload
import com.transport_system.ts_driver.telecom.service.CallConnection

class FirebaseMessagingService : FirebaseMessagingService() {

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d("FCM", "New token: $token")
        // Send token to your server if needed
    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)


        // Check if the message contains a data payload
        remoteMessage.data.let {
            Log.d("FCM", "Message data payload: $it")
            // Handle data message
        }


        remoteMessage.data.let {
            if(it["notification_type"] == "call"){
                try {
                    Log.d("FCM", "Call FCM payload ===> $it")
                    val callPayload = CallPayload.fromMap(map = remoteMessage.data)

                    val declined = it["incomming_declined"]
                    if (declined == "1" || declined.equals("true", ignoreCase = true)){
                        CallManager(context = applicationContext).incomingCallDecline(callPayload = callPayload)
                    }
                    else if (getTimeDifference(callPayload.callPlacedAt) >= 35){
                        AppNotificationManager(context = applicationContext).showMiscallNotification(callPayload = callPayload)
                    }
                    else if (CallConnection.currentConnection == null && AgoraManager.instance.callViewModel.currentCall.value == null){
                        CallManager(context = applicationContext).reportIncommingCall(callPayload = callPayload)
                    }
                    else{
                        CallEventHelper.userBusy(payload =  callPayload, context = applicationContext)
                    }
                }
                catch (_: Exception){}
            }
        }

    }


    private fun getTimeDifference(callPlacedAt :  String?): Long {
        return try {
            val currentTime = System.currentTimeMillis()
            val callTime = callPlacedAt?.toLongOrNull()
             if (callTime != null) {
                ((currentTime - callTime) / 1000)
            } else {
                0
            }
        }
        catch (_:Exception){
             0
        }
    }
}
