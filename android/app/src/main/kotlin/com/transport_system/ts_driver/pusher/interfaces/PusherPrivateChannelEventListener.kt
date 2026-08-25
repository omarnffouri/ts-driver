package com.transport_system.ts_driver.pusher.interfaces

import com.pusher.client.channel.PrivateChannel
import com.pusher.client.channel.PrivateChannelEventListener
import com.transport_system.ts_driver.helpers.AppLogger

abstract class PusherPrivateChannelEventListener : PrivateChannelEventListener {

    private var isBound = false

    abstract fun getChannel() : PrivateChannel?

    abstract fun getEventName() : String

    /**
     * This function will check if listener is not already bounded then
     * it will get private channel by calling [getChannel] and then it will fetch
     * event name by calling [getEventName] and will bind the event listener.
     * Once it is bounded calling [bind] multiple times will do nothing.
     * */
    fun bind() {
        try{
            if(!isBound){
                getChannel()?.bind(getEventName(), this)
                isBound = true
            }
            else {
                AppLogger.log("${getEventName()} event listener already bounded")
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception on binding ${getEventName()} event ===> ${e.message}")
        }
    }


    /**
     * This function will check if listener is bounded then
     * it will get private channel by calling [getChannel] and then it will fetch
     * event name by calling [getEventName] and will unbind the event listener.
     * Once it is unbounded calling [unbind] multiple times will do nothing.
     * */
    fun unbind() {
        try{
            if(isBound){
                getChannel()?.unbind(getEventName(),this)
                isBound = false
            }
            else{
                AppLogger.log("${getEventName()} event listener already not bounded")
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception on unbinding ${getEventName()} event ===> ${e.message}")
        }
    }

    override fun onSubscriptionSucceeded(channelName: String?) {
        AppLogger.log(" $channelName subscription succeeded.")
    }

    override fun onAuthenticationFailure(message: String?, e: java.lang.Exception?) {
        AppLogger.log("${getEventName()} event authentication failed ===> message : $message, exception : ${e?.message}")
    }

}