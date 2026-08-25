package com.transport_system.ts_driver.pusher.channels.call_channel.events

import android.annotation.SuppressLint
import android.content.Context
import com.google.gson.Gson
import com.pusher.client.channel.PrivateChannel
import com.pusher.client.channel.PusherEvent
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.pusher.channels.call_channel.channel.CallChannel
import com.transport_system.ts_driver.pusher.channels.call_channel.enums.CallChannelEvents
import com.transport_system.ts_driver.pusher.channels.call_channel.models.CallEventDataModel
import com.transport_system.ts_driver.pusher.interfaces.PusherPrivateChannelEventListener


class CallRingingEvent private constructor(private val context: Context) : PusherPrivateChannelEventListener() {


    companion object {
        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var instance: CallRingingEvent? = null

        fun initialize(context: Context): CallRingingEvent {
            val appContext = context.applicationContext
            return instance ?: synchronized(this) {
                instance ?: CallRingingEvent(appContext).also { instance = it }
            }
        }

    }

    override fun getChannel(): PrivateChannel? {
        return CallChannel.instance.getCallChannel(context = context)
    }

    override fun getEventName(): String {
        return CallChannelEvents.CALL_RINGING.getName()
    }

    override fun onEvent(event: PusherEvent?) {
        try {
            AppLogger.log("Got a ringing event data : ${event?.data}")
            val data = Gson().fromJson(event!!.data, CallEventDataModel::class.java)
            AppLogger.log("Call ringing event parsed successfully")

            if (data.conversationType == "group") {
                return
            }

            val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
            val conversationId = currentCall.callPayload.conversationId ?: return
            if (conversationId == data.conversationId) {
                context.sendBroadcast(
                    CallBroadcastReceiver.buildBroadcastIntent(
                        context = context,
                        action = CallBroadcastActions.ACTION_CALL_OUTGOING_RINGING,
                        data = currentCall.callPayload.toBundle()
                    )
                )
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception on event received in call ringing event ===> ${e.message}")
        }
    }

    override fun onSubscriptionSucceeded(channelName: String?) {
        AppLogger.log("Call ringing event subscription succeeded on channel : $channelName")
    }

    override fun onAuthenticationFailure(message: String?, e: java.lang.Exception?) {
        AppLogger.log("Call ringing event authentication failed ===> message : $message, exception : ${e?.message}")
    }
}