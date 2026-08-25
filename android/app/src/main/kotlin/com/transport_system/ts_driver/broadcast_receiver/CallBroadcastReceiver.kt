package com.transport_system.ts_driver.broadcast_receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.helpers.CallEventHelper
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEventChannel
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEvents
import com.transport_system.ts_driver.notification_managers.AppNotificationManager
import com.transport_system.ts_driver.notification_managers.CallNotificationService
import com.transport_system.ts_driver.notification_managers.OngoingCallNotificationService
import com.transport_system.ts_driver.telecom.models.CallPayload
import com.transport_system.ts_driver.telecom.service.CallConnection


class CallBroadcastReceiver : BroadcastReceiver() {


    companion object {

        fun buildBroadcastIntent(context: Context, action: CallBroadcastActions, data: Bundle) =
            Intent(context, CallBroadcastReceiver::class.java).apply {
                this.action = action.getName()
                putExtra("extra", data)
            }
    }


    override fun onReceive(broadcastContext: Context?, intent: Intent?) {
        Log.d("hashim", "received a call broadcast ===> ${intent?.action}")

        val context: Context = broadcastContext ?: return
        val action: String = intent?.action ?: return
        if (!CallBroadcastActions.entries.map { it.getName() }.contains(action)) {
            return
        }

        val callExtras: Bundle? = intent.extras?.getBundle("extra")
        val callPayload: CallPayload = getCallPayload(callExtras = callExtras) ?: return
        val appNotificationManager = AppNotificationManager(context = context)

        when (action) {

            ////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////// Incoming Call Events /////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////

            CallBroadcastActions.ACTION_CALL_INCOMING_RINGING.getName() -> {
                CallEventHelper.callRinging(payload = callPayload, context = context)
            }

            CallBroadcastActions.ACTION_CALL_INCOMING_DECLINED.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && (!currentCall.isOutGoing)) {
                    AgoraManager.instance.clearIncomingCall(callId = currentCall.uuid)
                    CallNotificationService.stop(context)
                    appNotificationManager.showMiscallNotification(callPayload = callPayload)
                    CallConnection.destroyCurrentConnection()
                }
            }

            CallBroadcastActions.ACTION_CALL_INCOMING_DECLINE.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && (!currentCall.isOutGoing)) {
                    CallEventHelper.callRejected(payload = callPayload, context = context)
                    AgoraManager.instance.clearIncomingCall(callId = currentCall.uuid)
                    CallNotificationService.stop(context)
                    CallConnection.destroyCurrentConnection()
                }
            }

            CallBroadcastActions.ACTION_CALL_INCOMING_ACCEPT.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.isOutGoing) {
                    return
                }
                AgoraManager.instance.incomingCallAccepted(
                    context = context,
                    callId = currentCall.uuid
                )
                CallNotificationService.stop(context)
                CallConnection.currentConnection?.setActive()
            }

            CallBroadcastActions.ACTION_CALL_INCOMING_TIMEOUT.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && (!currentCall.isOutGoing)) {
                    if ((!currentCall.hasStartedConnecting) && (!currentCall.hasConnected)) {
                        CallEventHelper.callTimeOut(payload = callPayload, context = context)
                        AgoraManager.instance.clearIncomingCall(callId = currentCall.uuid)
                        CallNotificationService.stop(context)
                        appNotificationManager.showMiscallNotification(callPayload = callPayload)
                        CallConnection.destroyCurrentConnection()
                    }
                }
            }


            ////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////
            ///////////////////////////// Outgoing Call Events /////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////
            ////////////////////////////////////////////////////////////////////////////////////////

            CallBroadcastActions.ACTION_CALL_OUTGOING_RINGING.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && currentCall.isOutGoing) {
                    AgoraManager.instance.callViewModel.updateOutGoingCallStatus(
                        callId = currentCall.uuid,
                        callState = CallState.RINGING
                    )
                }
            }

            CallBroadcastActions.ACTION_CALL_OUTGOING_DECLINED.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && currentCall.isOutGoing) {
                    AgoraManager.instance.clearOutGoingCall(
                        callId = currentCall.uuid,
                        callState = CallState.DECLINED
                    )
                    NativeCallingEventChannel.instance.sendEvent(
                        event = NativeCallingEvents.CALL_DECLINED,
                        data = currentCall.callPayload.toMap()
                    )
                    OngoingCallNotificationService.stop(context = context)
                    appNotificationManager.clearOngoingCallNotification()
                    CallConnection.destroyCurrentConnection()
                }
            }

            CallBroadcastActions.ACTION_CALL_OUTGOING_USER_BUSY.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && currentCall.isOutGoing) {
                    AgoraManager.instance.clearOutGoingCall(
                        callId = currentCall.uuid,
                        callState = CallState.USER_BUSY
                    )
                    NativeCallingEventChannel.instance.sendEvent(
                        event = NativeCallingEvents.CALL_USER_BUSY,
                        data = currentCall.callPayload.toMap()
                    )
                    OngoingCallNotificationService.stop(context = context)
                    appNotificationManager.clearOngoingCallNotification()
                    CallConnection.destroyCurrentConnection()
                }
            }

            CallBroadcastActions.ACTION_CALL_OUTGOING_TIMEOUT.getName(), CallBroadcastActions.ACTION_CALL_OUTGOING_NO_ANSWER.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload) && currentCall.isOutGoing) {
                    if (!currentCall.hasConnected) {
                        AgoraManager.instance.clearOutGoingCall(
                            callId = currentCall.uuid,
                            callState = CallState.NOT_ANSWERED
                        )
                        NativeCallingEventChannel.instance.sendEvent(
                            event = NativeCallingEvents.CALL_NO_ANSWER,
                            data = currentCall.callPayload.toMap()
                        )
                        OngoingCallNotificationService.stop(context = context)
                        appNotificationManager.clearOngoingCallNotification()
                        CallConnection.destroyCurrentConnection()
                    }
                }
            }


            //
            //
            // call end events

            CallBroadcastActions.ACTION_CALL_ENDED.getName() -> {
                val currentCall = AgoraManager.instance.callViewModel.currentCall.value ?: return
                if (currentCall.matches(callPayload)) {

                    //
                    // notify server that call has ended
                    val callViewModel = AgoraManager.instance.callViewModel
                    if (currentCall.hasConnected && (callViewModel.remoteUserJoined.value == true)) {
                        val duration = callViewModel.totalTicks.value ?: 0
                        if (duration > 0) {
                            CallEventHelper.callEnded(
                                payload = currentCall.callPayload,
                                context = context,
                                duration = duration
                            )
                        }
                    }
                    else if (currentCall.isOutGoing) {
                        CallEventHelper.ongoingCallDeclined(
                            payload = currentCall.callPayload,
                            context = context
                        )
                    }

                    try {
                        NativeCallingEventChannel.instance.sendEvent(
                            event = NativeCallingEvents.CALL_ENDED,
                            data = currentCall.callPayload.toMap()
                        )
                    } catch (e: Exception) {
                        AppLogger.log("Exception on emitting event to flutter layer on channel leave success ===> ${e.message}")
                    }

                    // ending call in agora and destroying call connection
                    AgoraManager.instance.endCall()
                    CallConnection.destroyCurrentConnection()
                    OngoingCallNotificationService.stop(context = context)
                    appNotificationManager.clearOngoingCallNotification()
                }
            }

        }

    }


    private fun getCallPayload(callExtras: Bundle?): CallPayload? {
        return if (callExtras == null) {
            null
        } else {
            try {
                return CallPayload.fromBundle(callExtras)
            } catch (_: Exception) {
                null
            }
        }
    }
}