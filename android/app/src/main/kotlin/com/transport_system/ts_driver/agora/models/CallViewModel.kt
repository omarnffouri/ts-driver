package com.transport_system.ts_driver.agora.models

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.apis.StartCallRecordingApi
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.data_providers.MyDetails
import com.transport_system.ts_driver.data_providers.database.DatabaseManager
import com.transport_system.ts_driver.data_providers.models.common.ParticipantModel
import com.transport_system.ts_driver.data_providers.models.group.GroupSettingsModel
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEventChannel
import com.transport_system.ts_driver.native_calling_plugin.NativeCallingEvents
import com.transport_system.ts_driver.telecom.models.Call
import com.transport_system.ts_driver.telecom.models.CallPayload
import java.util.Timer
import java.util.UUID
import kotlin.concurrent.timer

class CallViewModel : ViewModel() {

    //
    //
    // User and Call Details
    private val _currentCall = MutableLiveData<Call?>()
    val currentCall: LiveData<Call?> = _currentCall

    private val _groupSettings = MutableLiveData<GroupSettingsModel?>()
    val groupSettings: LiveData<GroupSettingsModel?> = _groupSettings

    private val _participants = MutableLiveData<List<ParticipantModel>>(emptyList())
    val participants: LiveData<List<ParticipantModel>> = _participants

    private val _callUsers = MutableLiveData<List<CallUser>>()
    val callUsers: LiveData<List<CallUser>> = _callUsers

    private val _selectedCallUser = MutableLiveData<CallUser?>()
    val selectedCallUser: LiveData<CallUser?> = _selectedCallUser

    var myDetails: MyDetails? = null


    //
    //
    //
    // Call State/Data Variables
    private val _myPid = MutableLiveData<Int?>()
    val myPid: LiveData<Int?> = _myPid


    private val _remoteUserJoined = MutableLiveData<Boolean>()
    val remoteUserJoined: LiveData<Boolean> = _remoteUserJoined

    private val _audioMuted = MutableLiveData<Boolean>()
    val audioMuted: LiveData<Boolean> = _audioMuted

    private val _videoMuted = MutableLiveData<Boolean>()
    val videoMuted: LiveData<Boolean> = _videoMuted

    private val _speakerEnabled = MutableLiveData<Boolean>()
    val speakerEnabled: LiveData<Boolean> = _speakerEnabled

    private var isStartingRecording = false

    private val _callRecording = MutableLiveData<StartCallRecordingResponseModel?>()
    private val callRecording: LiveData<StartCallRecordingResponseModel?> = _callRecording

    private val _callState = MutableLiveData<CallState>()
    val callState: LiveData<CallState> = _callState


    //
    //
    //
    // Call Time Variables
    private val _hours = MutableLiveData<Int>()
    val hours: LiveData<Int> = _hours

    private val _minutes = MutableLiveData<Int>()
    val minutes: LiveData<Int> = _minutes

    private val _seconds = MutableLiveData<Int>()
    val seconds: LiveData<Int> = _seconds

    private val _totalTicks = MutableLiveData<Int>()
    val totalTicks: LiveData<Int> = _totalTicks

    // Timer variable
    private var callTimer: Timer? = null


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

    fun resetSelf() {
        //
        // resetting user and call data variables
        _currentCall.value = null
        _groupSettings.value = null
        _participants.value = emptyList()
        _callUsers.value = emptyList()
        _selectedCallUser.value = null

        //
        // resetting call states etc
        _myPid.value = null
        _remoteUserJoined.value = false
        _audioMuted.value = false
        _videoMuted.value = false
        _speakerEnabled.value = true
        _callRecording.value = null
        _callState.value = CallState.IDLE

        //
        // resetting call time variables
        _hours.value = 0
        _minutes.value = 0
        _seconds.value = 0
        _totalTicks.value = 0
        stopCallTime()
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Agora callbacks related function ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

    fun onRemoteUserLeave(uid: Int, onEndCall: () -> Unit) {
        if (selectedCallUser.value?.remoteId == uid) {
            _selectedCallUser.value = null
        }
        _callUsers.value = callUsers.value?.filter { it.remoteId != uid }
        if (callUsers.value?.isEmpty() == true) {
            val callPayload = currentCall.value?.callPayload
            if (callPayload?.conversationType == "group" && callPayload.callType == "video" && selectedCallUser.value != null) {
                AppLogger.log("Still have user in group video call can't end")
                return
            }
            onEndCall()
        }
    }


    fun onRemoteUserJoined(uid: Int) {

        _remoteUserJoined.value = true
        startCallRecording()
        startCallTimer()
        currentCall.value?.callConnected()

        if (callState.value != CallState.CONNECTED) {
            _callState.value = CallState.CONNECTED
        }

        val participant = participants.value?.firstOrNull {
            val pid = it.pid ?: return@firstOrNull false
            return@firstOrNull pid == uid
        }

        val user = CallUser(remoteId = uid, participant = participant)

        val alreadyExist = callUsers.value?.firstOrNull { it.remoteId == user.remoteId } != null

        if (!alreadyExist) {
            if (callUsers.value == null) {
                _callUsers.value = listOf(user)
            } else {
                _callUsers.value = (callUsers.value!!.plus(user))
            }
        }
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Call controls related function //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

    fun muteAudio(mute: Boolean) {
        _audioMuted.value = mute
    }

    fun muteVideo(mute: Boolean) {
        _videoMuted.value = mute
    }

    fun enableSpeaker(enabled: Boolean) {
        _speakerEnabled.value = enabled
    }

    fun endCall() {
        resetSelf()
    }

    fun onRemoteUserSelected(user: CallUser?) {
        var users = callUsers.value ?: listOf()

        if (selectedCallUser.value != null) {
            AppLogger.log("Adding the current selected users in users list ===> onRemoteUserSelected in viewModel")
            users = users.plus(selectedCallUser.value!!)
        }

        if (user != null) {
            val userToRemove = users.firstOrNull { it.remoteId == user.remoteId }
            if (userToRemove != null) {
                AppLogger.log("Removing new selected user from the users list ===> onRemoteUserSelected in viewModel")
                users = users.minus(userToRemove)
            }
        }
        _selectedCallUser.value = user
        _callUsers.value = users
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Outgoing call related function //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


    suspend fun placeCall(context: Context, call: Call): Boolean {
        resetSelf()
        _currentCall.value = call
        _callState.value = CallState.CALLING
        return loadCallData(context = context)
    }

    fun updateOutGoingCallStatus(callId: UUID, callState: CallState) {
        val call = currentCall.value ?: return
        if (callId == call.uuid) {
            stopCallTime()
            _callState.value = callState
            AgoraManager.instance.updateCallStateInNotification(
                callPayload = currentCall.value?.callPayload,
                callState = callState,
                currentCall.value?.isOutGoing ?: false
            )
        }
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// Incoming call related function //////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////

    suspend fun incomingCallAccepted(context: Context, callId: UUID): Boolean {
        AppLogger.log("Accepting call in callViewModel ===> onCallAccept")
        val call = _currentCall.value ?: return false
        if (call.uuid != callId) {
            return false
        }
        _callState.value = CallState.CONNECTING
        return loadCallData(context = context)
    }

    fun reportIncomingCall(call: Call) {
        resetSelf()
        _currentCall.value = call
    }

    fun clearIncomingCall(callId: UUID) {
        val call = currentCall.value ?: return
        if (callId == call.uuid) {
            resetSelf()
        }
    }


    ////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////// Call Data loader and validator functions /////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////

    fun callFailed() {
        stopCallTime()
        _callState.value = CallState.FAILED
    }

    private suspend fun loadCallData(context: Context): Boolean {
        myDetails = MyDetails.loadFromSharedPrefs(context = context) ?: return false
        AppLogger.log("my details loaded in load call data")

        val callPayload = currentCall.value?.callPayload ?: return false
        AppLogger.log("call payload check passed in loadCallData")

        if (!validateCallParams(callPayload = callPayload)) {
            AppLogger.log("call data validation failed in load call data")
            return false
        }

        return if (callPayload.conversationType == "group") {
            loadGroupCallCallData(context = context)
        } else {
            loadOtoCallCallData(context = context)
        }


    }

    private suspend fun loadOtoCallCallData(context: Context): Boolean {
        val conversation = DatabaseManager.instance.fetchOtoConversation(
            conversationId = currentCall.value!!.callPayload.conversationId!!,
            context = context
        ) ?: return false
        AppLogger.log("oto conversation found in loadOtoCallCallData")
        val participants = conversation.participants ?: return false
        AppLogger.log("participants list found in loadOtoCallCallData")
        return loadParticipantsAndPid(participants = participants)
    }

    private suspend fun loadGroupCallCallData(context: Context): Boolean {
        val groupConversation = DatabaseManager.instance.fetchGroupConversation(
            conversationId = currentCall.value!!.callPayload.conversationId!!,
            context = context
        ) ?: return false
        AppLogger.log("group conversation found in loadGroupCallCallData")
        _groupSettings.value = groupConversation.groupSettings
        val participants = groupConversation.participants ?: return false
        AppLogger.log("participants list found in loadGroupCallCallData")
        return loadParticipantsAndPid(participants = participants)
    }

    private fun loadParticipantsAndPid(participants: List<ParticipantModel>): Boolean {
        val me = myDetails ?: return false
        AppLogger.log("my details check passed in loadParticipantsAndPid")
        AppLogger.log(" total participants found ====> ${participants.size}")
        val myPid = participants.firstOrNull { participant ->
            val id = participant.id ?: return@firstOrNull false
            val modelType = participant.modelType ?: return@firstOrNull false
            AppLogger.log("participant name ===> ${participant.name} ==> id ==> $id ===> model type ===> $modelType")
            return@firstOrNull me.applicantId?.toInt() == id && me.modelType == modelType
        }?.pid ?: return false

        AppLogger.log("my pid found in loadParticipantsAndPid")
        _participants.value = participants
        _myPid.value = myPid
        return true
    }

    private fun validateCallParams(callPayload: CallPayload): Boolean {
        if (callPayload.conversationId == null) {
            AppLogger.log("conversation id is nil while accepting the call")
            return false
        }
        if (callPayload.channelName == null) {
            AppLogger.log("channel name is nil while accepting the call")
            return false
        }
        if (callPayload.conversationType != "oto" && callPayload.conversationType != "group") {
            AppLogger.log("conversation type is nil or invalid while accepting the call ===> ${callPayload.conversationType}")
            return false
        }
        return true
    }


//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////// Other helper function ////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


    fun getOppositeUser(): ParticipantModel? {
        val myPid = myPid.value ?: return null
        if (!callUsers.value.isNullOrEmpty()) {
            return callUsers.value?.first()?.participant
        }
        return participants.value?.firstOrNull { participant ->
            val pid = participant.pid ?: return@firstOrNull false
            return@firstOrNull pid != myPid
        }
    }


    fun getReceiverImage(): String? {
        return if (groupSettings.value != null) {
            groupSettings.value!!.logo
        } else {
            getOppositeUser()?.image
        }
    }


    private fun startCallTimer() {
        AppLogger.log("Start call time function called")

        if (callTimer != null) {
            AppLogger.log("Call time is already running and not null")
            return
        }

        _totalTicks.value = 0
        _hours.value = 0
        _minutes.value = 0
        _seconds.value = 0

        AppLogger.log("About start a call timer in call view model")
        callTimer = timer("call_time", true, 1000, 1000) {
            try {
                Handler(Looper.getMainLooper()).post {
                    _totalTicks.value = (_totalTicks.value ?: 0) + 1
                    _hours.value = (totalTicks.value ?: 0) / 3600
                    _minutes.value = ((totalTicks.value ?: 0) % 3600) / 60
                    _seconds.value = (totalTicks.value ?: 0) % 60
                    AppLogger.log("Call time ====> ${_totalTicks.value}")

                    AgoraManager.instance.updateCallTimeInNotification(
                        callPayload = currentCall.value?.callPayload,
                        hours = hours.value,
                        minutes = minutes.value,
                        seconds = seconds.value,
                        isOutgoing = currentCall.value?.isOutGoing ?: false
                    )

                    NativeCallingEventChannel.instance.sendEvent(
                        event = NativeCallingEvents.CALL_TIME, data = mapOf(
                            "hours" to hours.value,
                            "minutes" to minutes.value,
                            "seconds" to seconds.value
                        )
                    )
                }
            } catch (e: Exception) {
                AppLogger.log("exception while updating call time ===> ${e.message}")
            }

        }
    }


    private fun stopCallTime() {
        callTimer?.cancel()
        callTimer = null
    }


    private fun startCallRecording() {
        try {
            if (isStartingRecording || myDetails == null || callRecording.value != null) {
                return
            }

            val messageId = currentCall.value?.callPayload?.messageId ?: return
            val channelName = currentCall.value?.callPayload?.channelName ?: return

            isStartingRecording = true

            StartCallRecordingApi.startRecording(
                myDetails = myDetails!!,
                messageId = messageId,
                channelName = channelName,
                onSuccess = { data ->
                    _callRecording.value = data
                    isStartingRecording = false
                })
        } catch (e: Exception) {
            isStartingRecording = false
            AppLogger.log("Exception while starting call recording in call view model ===> ${e.message}")
        }
    }

}
