package com.transport_system.ts_driver.telecom.managers

import android.annotation.SuppressLint
import android.content.Context
import android.net.Uri
import android.os.Bundle
import android.telecom.TelecomManager
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.telecom.models.Call
import com.transport_system.ts_driver.telecom.models.CallPayload
import com.transport_system.ts_driver.telecom.service.CallConnection

class CallManager(private val context: Context) {



    fun reportIncommingCall(callPayload: CallPayload){
        val telecomManager = PhoneAccountManager.getTelecomManager(context = context)
        val phoneAccountHandle = PhoneAccountManager.getPhoneAccountHandler(context = context)

        val uri = Uri.fromParts("tel", callPayload.callerName ?: "", null)
        val bundle = Bundle().apply {
            putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, phoneAccountHandle)
            putParcelable(TelecomManager.EXTRA_INCOMING_CALL_ADDRESS, uri)
            putBundle(TelecomManager.EXTRA_INCOMING_CALL_EXTRAS, callPayload.toBundle())
        }
        telecomManager.addNewIncomingCall(phoneAccountHandle, bundle)
    }


    @SuppressLint("MissingPermission")
    fun placeCall(call: Call){
        try{
            val telecomManager = PhoneAccountManager.getTelecomManager(context = context)
            val phoneAccountHandle = PhoneAccountManager.getPhoneAccountHandler(context = context)
            val uri = Uri.fromParts("tel", call.callPayload.receiverName ?: "", null)
            val bundle = Bundle().apply {
                putParcelable(TelecomManager.EXTRA_PHONE_ACCOUNT_HANDLE, phoneAccountHandle)
                putBundle(TelecomManager.EXTRA_OUTGOING_CALL_EXTRAS, call.callPayload.toBundle())
            }
            telecomManager.placeCall(uri,bundle)
        }
        catch (e:Exception){
            AppLogger.log("Exception in call manager while placing the call ===> ${e.message}")
        }
    }



    fun incomingCallDecline(callPayload: CallPayload){
        AppLogger.log("Got incomming decline notification ===> tempCallId=${callPayload.tempCallId}, conversationId=${callPayload.conversationId}")
        val currentCall = AgoraManager.instance.callViewModel.currentCall.value
        if (CallConnection.currentConnection == null || currentCall == null || currentCall.isOutGoing) {
            AppLogger.log("Incomming decline ignored ===> no matching ringing call")
            return
        }

        if (currentCall.matches(callPayload)) {
            AppLogger.log("Incomming decline matched ===> clearing ringing call")
            // Forward the live payload so the missed-call notification keeps the ringing caller's info.
            val intent = CallBroadcastReceiver.buildBroadcastIntent(
                context = context,
                action = CallBroadcastActions.ACTION_CALL_INCOMING_DECLINED,
                data = currentCall.callPayload.toBundle()
            )
            context.sendBroadcast(intent)
        } else {
            AppLogger.log("Incomming decline did not match current call ===> live uuid=${currentCall.uuid}, live conversationId=${currentCall.callPayload.conversationId}")
        }
    }
}