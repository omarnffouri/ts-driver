package com.transport_system.ts_driver.pusher.manager

import android.content.Context
import com.pusher.client.Pusher
import com.pusher.client.PusherOptions
import com.pusher.client.connection.ConnectionState
import com.pusher.client.util.HttpChannelAuthorizer
import com.transport_system.ts_driver.data_providers.MyDetails
import com.transport_system.ts_driver.helpers.AppLogger

class PusherManager {


    private var pusher: Pusher? = null

    companion object {
        val instance = PusherManager()
    }

    fun initialize(context: Context) {
        try {
            if(isConnected()){
                return
            }
            val myDetails = MyDetails.loadFromSharedPrefs(context = context)
            pusher = Pusher(getAppKey(context = context), PusherOptions().apply {
                setHost(getHost(context = context))
                setWssPort(getPort(context = context))
                setUseTLS(true)
                setChannelAuthorizer(HttpChannelAuthorizer(getAuthUrl(context = context)).apply {
                    setHeaders(
                        mapOf(
                            "Authorization" to "Bearer ${myDetails?.token}",
                            "Accept" to "application/json"
                        )
                    )
                })
            })
            pusher?.connect(PusherConnectionStateListener(pusherManager = this))
        }
        catch (e:Exception){
            AppLogger.log("Exception while initializing the pusher ====> ${e.message}")
        }
    }

    fun getPusher(context: Context) : Pusher?{
        if (pusher == null){
            initialize(context = context)
        }
        return pusher
    }

    private fun isConnected() : Boolean {
        return pusher?.connection?.state == ConnectionState.CONNECTED
    }

    fun ensureConnection(context: Context) {
        try {
            if(!isConnected()){
                if(pusher == null){
                    initialize(context = context)
                    return
                }
                pusher?.connect()
            }
            else{
                AppLogger.log("Pusher socket is already connected.")
            }
        }
        catch (e:Exception){
            AppLogger.log("Exception while ensure pusher socket connection called ===> ${e.message} ")
        }
    }

    // Realtime config comes from the server (mirrored into SharedPreferences by
    // Dart). We honor it as the source of truth; the env-based hardcoded values
    // are only a fallback for the window before the first config fetch.
    private fun getAppKey(context: Context): String =
        MyDetails.realtimeKey(context = context) ?: when {
            MyDetails.isProduction(context = context) -> "HiXzy5MIniPeS24McIZ1VdIrZ"
            MyDetails.isStaging(context = context) -> "E17C5BA4D29185A3"
            else -> "9dbf5c6a056f4d4f99561fcf43f8a566" // development
        }

    private fun getHost(context: Context): String =
        MyDetails.realtimeHost(context = context) ?: when {
            MyDetails.isProduction(context = context) -> "socket.ts-portal.com"
            MyDetails.isStaging(context = context) -> "staging.ts-portal.com"
            else -> "dev.ts-portal.com" // development
        }

    private fun getPort(context: Context): Int =
        MyDetails.realtimePort(context = context) ?: 2096

    private fun getAuthUrl(context: Context): String =
        MyDetails.realtimeAuthUrl(context = context) ?: "https://${
            if (MyDetails.isStaging(context = context)) "staging." else if (MyDetails.isDevelopment(
                    context = context
                )
            ) "dev." else ""
        }ts-portal.com/broadcasting/auth"

}