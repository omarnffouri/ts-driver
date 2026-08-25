package com.transport_system.ts_driver.agora.extensions

import android.os.Handler
import android.os.Looper
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEventChannel
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEvents
import com.transport_system.ts_driver.telecom.service.CallConnection
import io.agora.rtc2.IRtcEngineEventHandler
import io.agora.rtc2.RtcConnection.CONNECTION_STATE_TYPE


class AgoraEventHandlers(private val agoraManager: AgoraManager) : IRtcEngineEventHandler() {

    override fun onError(err: Int) {
        super.onError(err)
        try {
            Handler(Looper.getMainLooper()).post {
                AppLogger.log("Agora onError in agora callback ===> error_id : $err")
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on onError in agora callback ===> ${e.message}")
        }
    }

    override fun onJoinChannelSuccess(channel: String?, uid: Int, elapsed: Int) {
        super.onJoinChannelSuccess(channel, uid, elapsed)
        AppLogger.log("Me joined channel ($channel) successfully with uid ($uid)")

        try {
            val currentCall = agoraManager.callViewModel.currentCall.value ?: return
           if(currentCall.isOutGoing){
               Handler(Looper.getMainLooper()).post {
                   NativeCallingEventChannel.instance.sendEvent(
                       event = NativeCallingEvents.CALL_PLACED,
                       data = currentCall.callPayload.toMap()
                   )
               }
           }
            else{
               Handler(Looper.getMainLooper()).post {
                   NativeCallingEventChannel.instance.sendEvent(
                       event = NativeCallingEvents.CALL_RECEIVED,
                       data = currentCall.callPayload.toMap()
                   )
               }
           }
        } catch (e: Exception) {
            AppLogger.log("Exception on emitting event to flutter layer on channel joined success ===> ${e.message}")
        }

    }

    override fun onLeaveChannel(stats: RtcStats?) {
        super.onLeaveChannel(stats)
        AppLogger.log("Me leaved the channel.")
    }

    override fun onUserJoined(uid: Int, elapsed: Int) {
        super.onUserJoined(uid, elapsed)
        AppLogger.log("Remote user joined the channel with uid: $uid, elapsed: $elapsed")
        try {
            Handler(Looper.getMainLooper()).post {
                agoraManager.callViewModel.onRemoteUserJoined(uid = uid)
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on remote user joined ===> ${e.message}")
        }

    }

    override fun onUserOffline(uid: Int, reason: Int) {
        super.onUserOffline(uid, reason)
        AppLogger.log("Remote user left the channel with uid: $uid, reason: $reason")
        try {
            Handler(Looper.getMainLooper()).post {
                val callViewModel = agoraManager.callViewModel
                callViewModel.onRemoteUserLeave(uid = uid, onEndCall = {
                    AppLogger.log("Ending call on all users left")
                    val context = CallConnection.currentConnection?.context
                    if (context != null && callViewModel.currentCall.value != null) {
                        context.sendBroadcast(
                            CallBroadcastReceiver.buildBroadcastIntent(
                                context = context,
                                action = CallBroadcastActions.ACTION_CALL_ENDED,
                                data = callViewModel.currentCall.value!!.callPayload.toBundle()
                            )
                        )
                    }
                })
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on remote user leave ===> ${e.message}")
        }
    }

    override fun onActiveSpeaker(uid: Int) {
        super.onActiveSpeaker(uid)
        AppLogger.log("User active speaker state updated ===> uid: $uid")
        try {
            Handler(Looper.getMainLooper()).post {
                val callViewModel = agoraManager.callViewModel
                callViewModel.selectedCallUser.value?.isSpeaking?.value =
                    (callViewModel.selectedCallUser.value?.remoteId == uid)
                callViewModel.callUsers.value?.forEach { user ->
                    user.isSpeaking.value = (user.remoteId == uid)
                }
            }
        } catch (e: Exception) {
            AppLogger.log("Exception while updating active speaker states of users ===> ${e.message}")
        }
    }

    override fun onUserMuteAudio(uid: Int, muted: Boolean) {
        super.onUserMuteAudio(uid, muted)
        AppLogger.log("User mic mute state updated ===> uid: $uid, mute: $muted")
        try {
            Handler(Looper.getMainLooper()).post {
                val callViewModel = agoraManager.callViewModel
                if (callViewModel.selectedCallUser.value?.remoteId == uid) {
                    callViewModel.selectedCallUser.value!!.micMuted.value = muted
                } else {
                    callViewModel.callUsers.value?.firstOrNull { it.remoteId == uid }?.micMuted?.value =
                        muted
                }
            }
        } catch (e: Exception) {
            AppLogger.log("Exception while updating mic mute states of users ===> ${e.message}")
        }
    }

    override fun onUserMuteVideo(uid: Int, muted: Boolean) {
        super.onUserMuteVideo(uid, muted)
        AppLogger.log("User video mute state updated ===> uid: $uid, mute: $muted")
        try {
            Handler(Looper.getMainLooper()).post {
                val callViewModel = agoraManager.callViewModel
                if (callViewModel.selectedCallUser.value?.remoteId == uid) {
                    callViewModel.selectedCallUser.value!!.videoMuted.value = muted
                } else {
                    callViewModel.callUsers.value?.firstOrNull { user -> user.remoteId == uid }?.videoMuted?.value =
                        muted
                }
            }
        } catch (e: Exception) {
            AppLogger.log("Exception while updating video mute states of users ===> ${e.message}")
        }
    }

    override fun onTokenPrivilegeWillExpire(token: String?) {
        super.onTokenPrivilegeWillExpire(token)
        AppLogger.log("Token Privilege will expire in agora callback handler")
        try {
            Handler(Looper.getMainLooper()).post {
                agoraManager.refreshAgoraToken()
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on token privilege will expire ===> ${e.message}")
        }
    }

    override fun onRequestToken() {
        super.onRequestToken()
        AppLogger.log("Requesting token in agora callback handler")
        try {
            Handler(Looper.getMainLooper()).post {
                agoraManager.refreshAgoraToken()
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on requesting token in agora callback ===> ${e.message}")
        }
    }

    override fun onConnectionStateChanged(state: Int, reason: Int) {
        super.onConnectionStateChanged(state, reason)
        try {
            Handler(Looper.getMainLooper()).post {
                AppLogger.log("Agora connection state changed to ===> $state")
                if (state == CONNECTION_STATE_TYPE.getValue(CONNECTION_STATE_TYPE.CONNECTION_STATE_FAILED) &&
                    agoraManager.callViewModel.callState.value != CallState.CONNECTED){
                    agoraManager.callFailed()
                }
            }
        } catch (e: Exception) {
            AppLogger.log("Exception on onConnectionStateChanged in agora callback ===> ${e.message}")
        }
    }

}

