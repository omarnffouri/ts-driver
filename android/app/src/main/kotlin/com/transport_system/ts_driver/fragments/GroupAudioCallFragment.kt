package com.transport_system.ts_driver.fragments

import android.graphics.PorterDuff
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.GridLayoutManager
import com.squareup.picasso.Picasso
import com.transport_system.ts_driver.R
import com.transport_system.ts_driver.activities.CallActivity
import com.transport_system.ts_driver.adapaters.GroupAudioCallUserAdapter
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.agora.models.CallUser
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.databinding.FragmentGroupAudioCallBinding
import com.transport_system.ts_driver.helpers.AppLogger
import java.util.ArrayList


class GroupAudioCallFragment(private val callActivity: CallActivity) : Fragment() {

    private lateinit var binding : FragmentGroupAudioCallBinding
    private val agoraManager = AgoraManager.instance
    private val callViewModel = agoraManager.callViewModel


    private var adapter = GroupAudioCallUserAdapter(callUser = ArrayList<CallUser>())


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentGroupAudioCallBinding.inflate(inflater,container,false)
        loadData()
        setOnClickListeners()
        attachObservers()
        return binding.root
    }


    private fun loadData() {
        binding.groupName.text = callViewModel.groupSettings.value?.name ?: "Group Audio Call"
        binding.callTime.text = callViewModel.callState.value?.getName()
        try {
            Picasso.get().load(callViewModel.groupSettings.value?.logo)
                .into(binding.groupImage)
        } catch (_: Exception) {
        }

        binding.callUsersRecyclerView.layoutManager = GridLayoutManager(callActivity,2)
        binding.callUsersRecyclerView.adapter = adapter
    }

    private fun setOnClickListeners() {

        binding.callControlView.btnMuteVideo.visibility = View.GONE
        binding.callControlView.btnSwitchCamera.visibility = View.GONE

        binding.callControlView.btnEndCall.setOnClickListener {
            val callPayload =
                callViewModel.currentCall.value?.callPayload ?: return@setOnClickListener
            callActivity.sendBroadcast(
                CallBroadcastReceiver.buildBroadcastIntent(
                    context = callActivity.applicationContext,
                    action = CallBroadcastActions.ACTION_CALL_ENDED,
                    data = callPayload.toBundle()
                )
            )
        }

        binding.backButton.setOnClickListener {
            if (!callActivity.isFinishing) {
                callActivity.finish()
            }
        }

        binding.callControlView.btnMuteAudio.setOnClickListener {
            agoraManager.toggleAudioMute()
        }

        binding.callControlView.btnSpeaker.setOnClickListener {
            agoraManager.toggleSpeakerEnable()
        }

    }

    private fun attachObservers() {
        listenForCallControlUpdates()
        listenForCallState()
        listenForCallTime()
        listenForCallUser()
    }

    private fun listenForCallControlUpdates() {
        AppLogger.log("Attaching call control observers in group audio call fragment")
        // listening audio mute state and updating button icon and style
        callViewModel.audioMuted.observe(viewLifecycleOwner) { muted ->
            AppLogger.log("Audio mute observer called in group audio call fragment ===> mute : $muted")
            binding.callControlView.btnMuteAudio.setBackgroundResource(if (muted) R.drawable.circle_white_background else R.drawable.circle_gray_background)
            binding.callControlView.btnMuteAudio.setImageResource(if (muted) R.drawable.mic_off else R.drawable.mic_on)
            binding.callControlView.btnMuteAudio.setColorFilter(
                ContextCompat.getColor(
                    callActivity, if (muted) R.color.colorPrimary else R.color.white
                ), PorterDuff.Mode.SRC_IN
            )
        }

        // listening speaker state and updating button icon and style
        callViewModel.speakerEnabled.observe(viewLifecycleOwner) { enabled ->
            AppLogger.log("Speaker observer called in oto video call fragment ===> enabled : $enabled")
            binding.callControlView.btnSpeaker.setBackgroundResource(if (enabled) R.drawable.circle_white_background else R.drawable.circle_gray_background)
            binding.callControlView.btnSpeaker.setImageResource(if (!enabled) R.drawable.speaker_off else R.drawable.speaker_on)
            binding.callControlView.btnSpeaker.setColorFilter(
                ContextCompat.getColor(
                    callActivity, if (enabled) R.color.colorPrimary else R.color.white
                ), PorterDuff.Mode.SRC_IN
            )
        }
    }

    private fun listenForCallState(){
        callViewModel.callState.observe(viewLifecycleOwner) { state ->
            binding.callTime.text = state.getName()
        }
    }

    private fun listenForCallTime() {
        callViewModel.hours.observe(viewLifecycleOwner) {
            updateCallTime()
        }
        callViewModel.minutes.observe(viewLifecycleOwner) {
            updateCallTime()
        }
        callViewModel.seconds.observe(viewLifecycleOwner) {
            updateCallTime()
        }
    }

    private fun updateCallTime() {

        val hours = callViewModel.hours.value ?: 0
        val minutes = callViewModel.minutes.value ?: 0
        val seconds = callViewModel.seconds.value ?: 0

        if (callViewModel.callState.value != CallState.CONNECTED && hours <= 0 && minutes <= 0 && seconds <= 0){
            return
        }

        // building time string
        var timeString = ""

        if(hours > 0){
            if (hours < 10){
                timeString += "0"
            }
            timeString += "$hours : "
        }

        if (minutes < 10){
            timeString += "0"
        }
        timeString += "$minutes : "

        if (seconds < 10){
            timeString += "0"
        }
        timeString += seconds.toString()

        binding.callTime.text = timeString
    }

    private fun listenForCallUser() {
        callViewModel.callUsers.observe(viewLifecycleOwner) { callUsers ->
            AppLogger.log("Call users list observer called in group audio call ====> list size : ${callUsers.size}")
            if (!callUsers.isNullOrEmpty()) {
                adapter.updateList(callUsers)
            }
        }
    }

    override fun onDestroyView() {
        callViewModel.audioMuted.removeObservers(viewLifecycleOwner)
        callViewModel.speakerEnabled.removeObservers(viewLifecycleOwner)
        callViewModel.hours.removeObservers(viewLifecycleOwner)
        callViewModel.minutes.removeObservers(viewLifecycleOwner)
        callViewModel.seconds.removeObservers(viewLifecycleOwner)
        callViewModel.callState.removeObservers(viewLifecycleOwner)
        callViewModel.callUsers.removeObservers(viewLifecycleOwner)
        super.onDestroyView()
    }

}