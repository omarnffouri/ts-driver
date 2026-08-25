package com.transport_system.ts_driver.pusher.channels.call_channel.channel

import android.content.Context
import com.pusher.client.channel.PrivateChannel
import com.pusher.client.channel.PrivateChannelEventListener
import com.pusher.client.channel.PusherEvent
import com.transport_system.ts_driver.data_providers.MyDetails
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.pusher.manager.PusherManager

class CallChannel {

    private var pusherManager = PusherManager.instance

    private var callChannel : PrivateChannel? = null


    companion object {
        val instance = CallChannel()
    }

    fun initialize(context: Context){
       try {
           if(callChannel?.isSubscribed == true){
               return
           }
           createAndSubscribeCallChannel(context = context)
       }
       catch (e:Exception){
           AppLogger.log("Exception while initializing the call channel ===> ${e.message}")
       }
    }

    fun getCallChannel(context: Context) : PrivateChannel? {
        try {
            pusherManager.ensureConnection(context = context)
            if(callChannel?.isSubscribed == false){
                createAndSubscribeCallChannel(context = context)
            }
            else{
                AppLogger.log("Call channel is subscribed while getting call channel.")
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception while getting call channel ===> ${e.message}")
        }
        return callChannel
    }

    private fun createAndSubscribeCallChannel(context: Context) {
        try {
            val myDetails = MyDetails.loadFromSharedPrefs(context = context) ?: return
            val modelType = myDetails.modelType ?: return
            val userId = myDetails.applicantId ?: return

            pusherManager.ensureConnection(context = context)

            if(callChannel?.isSubscribed == true){
                AppLogger.log("Call Channel already subscribed")
                return
            }

            callChannel = pusherManager.getPusher(context = context)?.subscribePrivate("private-call-receiver-$modelType-$userId",object : PrivateChannelEventListener{
                override fun onEvent(event: PusherEvent?) {
                    AppLogger.log("Private call channel event received ===> event.data : ${event?.data}")
                }

                override fun onSubscriptionSucceeded(channelName: String?) {
                    AppLogger.log("Private call channel subscription succeeded ===> channelName : $channelName")
                }

                override fun onAuthenticationFailure(message: String?, e: java.lang.Exception?) {
                    AppLogger.log("Private call channel authentication failed ===> message : $message, exception : ${e?.message}")
                }
            })
        }
        catch (e:Exception){
            AppLogger.log("Exception while creating and subscribing call channel ===> ${e.message}")
        }
    }


}