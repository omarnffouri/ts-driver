package com.transport_system.ts_driver.telecom.service

import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.PhoneAccountHandle
import android.telecom.TelecomManager
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.helpers.UUIDHelper
import com.transport_system.ts_driver.telecom.models.Call
import com.transport_system.ts_driver.telecom.models.CallPayload

class ConnectionService : ConnectionService() {



    override fun onCreateIncomingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle,
        request: ConnectionRequest
    ): Connection? {
       try{
           AppLogger.log("received a incomming call request.")
           //
           // parsing call payload from extras bundle
           val callPayloadBundle = request.extras.getBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS)!!
           val callPayload = CallPayload.fromBundle(callPayloadBundle)

           // creating and configuring a connection
           val connection = CallConnection(context = applicationContext, Call(uuid = UUIDHelper.parseUUID(uuid = callPayload.tempCallId), callPayload = callPayload, isOutGoing = false))
           connection.setAddress(request.address, TelecomManager.PRESENTATION_ALLOWED)
           connection.setCallerDisplayName(callPayload.callerName ?: "Unknown", TelecomManager.PRESENTATION_ALLOWED)
           connection.audioModeIsVoip = true
           connection.connectionProperties = Connection.PROPERTY_SELF_MANAGED
           connection.putExtras(callPayloadBundle)
           //
           // storing current connection and call
           CallConnection.currentConnection = connection
           // returning connection
           return connection
       }
       catch (e:Exception){
           CallConnection.destroyCurrentConnection()
           AppLogger.log("Exception while creating a incoming call connection on incoming call request ===> ${e.message}")
           return null
       }
    }

    override fun onCreateIncomingConnectionFailed(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ) {
        super.onCreateIncomingConnectionFailed(connectionManagerPhoneAccount, request)
    }

    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle,
        request: ConnectionRequest
    ): Connection? {
        try{
            AppLogger.log("received a outgoing call request. ==> ${request.extras}")

            //
            // parsing call payload from extras bundle
            val callPayload = CallPayload.fromBundle(request.extras)

            // creating and configuring a connection
            val connection = CallConnection(context = applicationContext, Call(uuid = UUIDHelper.parseUUID(uuid = callPayload.tempCallId), callPayload = callPayload, isOutGoing = true))
            connection.setAddress(request.address, TelecomManager.PRESENTATION_ALLOWED)
            connection.setCallerDisplayName(callPayload.receiverName ?: "Unknown", TelecomManager.PRESENTATION_ALLOWED)
            connection.audioModeIsVoip = true
            connection.connectionProperties = Connection.PROPERTY_SELF_MANAGED
            connection.putExtras(request.extras)
            connection.onShowIncomingCallUi()
            //
            // storing current connection and call
            CallConnection.currentConnection = connection
            // returning connection
            return connection
        }
        catch (e:Exception){
            CallConnection.destroyCurrentConnection()
            AppLogger.log("Exception while creating a outgoing call connection on outgoing call request ===> ${e.message}")
            e.printStackTrace()
            return null
        }
    }


    override fun onCreateOutgoingConnectionFailed(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest?
    ) {
        super.onCreateOutgoingConnectionFailed(connectionManagerPhoneAccount, request)
    }


}
