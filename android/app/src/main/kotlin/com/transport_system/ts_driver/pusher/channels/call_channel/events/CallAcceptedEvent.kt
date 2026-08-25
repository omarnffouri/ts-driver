package com.transport_system.ts_driver.pusher.channels.call_channel.events

import android.annotation.SuppressLint
import android.content.Context
import com.google.gson.Gson
import com.pusher.client.channel.PrivateChannel
import com.pusher.client.channel.PusherEvent
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.pusher.channels.call_channel.channel.CallChannel
import com.transport_system.ts_driver.pusher.channels.call_channel.enums.CallChannelEvents
import com.transport_system.ts_driver.pusher.channels.call_channel.models.CallEventDataModel
import com.transport_system.ts_driver.pusher.interfaces.PusherPrivateChannelEventListener


class CallAcceptedEvent private constructor(private val context: Context) :
    PusherPrivateChannelEventListener() {

    companion object {
        @SuppressLint("StaticFieldLeak")
        @Volatile
        private var instance: CallAcceptedEvent? = null

        fun initialize(context: Context): CallAcceptedEvent {
            val appContext = context.applicationContext
            return instance ?: synchronized(this) {
                instance ?: CallAcceptedEvent(appContext).also { instance = it }
            }
        }

    }

    override fun getChannel(): PrivateChannel? {
        return CallChannel.instance.getCallChannel(context = context)
    }

    override fun getEventName(): String {
        return CallChannelEvents.CALL_ACCEPTED.getName()
    }

    override fun onEvent(event: PusherEvent?) {
        try {
            AppLogger.log("Got a call accepted event data : ${event?.data}")
            val data = Gson().fromJson(event!!.data, CallEventDataModel::class.java)
            AppLogger.log("Call accepted event parsed successfully")
        }
        catch (e:Exception){
            AppLogger.log("Exception on event received in accept call event ===> ${e.message}")
        }
    }

    override fun onSubscriptionSucceeded(channelName: String?) {
        AppLogger.log("Call accept event subscription succeeded on channel : $channelName")
    }

    override fun onAuthenticationFailure(message: String?, e: java.lang.Exception?) {
        AppLogger.log("Call accept event authentication failed ===> message : $message, exception : ${e?.message}")
    }
}