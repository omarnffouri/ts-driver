package com.transport_system.ts_driver.pusher.manager

import com.pusher.client.connection.ConnectionEventListener
import com.pusher.client.connection.ConnectionStateChange
import com.transport_system.ts_driver.helpers.AppLogger
import java.lang.Exception

class PusherConnectionStateListener(private val pusherManager: PusherManager) : ConnectionEventListener {
    override fun onConnectionStateChange(change: ConnectionStateChange?) {
        // AppLogger.log("Pusher connection state changed from ${change?.previousState?.name} to ${change?.currentState?.name}.")
    }

    override fun onError(message: String?, code: String?, e: Exception?) {
        AppLogger.log("Error occurred in a pusher connection state listener ==> message : $message, code: $code, exception: ${e?.message}")
    }
}