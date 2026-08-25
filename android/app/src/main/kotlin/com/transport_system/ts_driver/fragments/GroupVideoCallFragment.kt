package com.transport_system.ts_driver.fragments

import android.graphics.PorterDuff
import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.core.content.ContextCompat
import androidx.lifecycle.Observer
import androidx.recyclerview.widget.GridLayoutManager
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.squareup.picasso.Picasso
import com.transport_system.ts_driver.R
import com.transport_system.ts_driver.activities.CallActivity
import com.transport_system.ts_driver.adapaters.GroupVideoCallUserAdapter
import com.transport_system.ts_driver.adapaters.GroupVideoCallUserSmallAdapter
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.agora.models.CallUser
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.databinding.FragmentGroupVideoCallBinding
import com.transport_system.ts_driver.helpers.AppLogger

class GroupVideoCallFragment(private val callActivity: CallActivity) : Fragment() {

    private lateinit var binding: FragmentGroupVideoCallBinding
    private val agoraManager = AgoraManager.instance
    private val callViewModel = agoraManager.callViewModel

    private val gridListAdapter = GroupVideoCallUserAdapter(callUser = ArrayList())
    private val smallListAdapter = GroupVideoCallUserSmallAdapter(callUser = ArrayList())


    private lateinit var selectedUserMicMuteObserver : Observer<Boolean>
    private lateinit var selectedUserVideoMuteObserver : Observer<Boolean>
    private var selectedUser : CallUser? = null

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        binding = FragmentGroupVideoCallBinding.inflate(inflater, container, false)
        loadData()
        setOnClickListeners()
        attachObservers()
        return binding.root
    }

    private fun loadData() {
        binding.groupName.text = callViewModel.groupSettings.value?.name ?: "Group Video Call"
        binding.callTime.text = callViewModel.callState.value?.getName()
        try {
            Picasso.get().load(callViewModel.groupSettings.value?.logo)
                .into(binding.groupImage)
        } catch (_: Exception) {
        }


        binding.remoteUsersBigRecyclerView.layoutManager = GridLayoutManager(callActivity, 2)
        binding.remoteUsersBigRecyclerView.adapter = gridListAdapter
        binding.remoteUsersBigRecyclerView.recycledViewPool.setMaxRecycledViews(0,0)

        binding.remoteUsersSmallRecyclerView.layoutManager =
            LinearLayoutManager(callActivity, RecyclerView.HORIZONTAL, false)
        binding.remoteUsersSmallRecyclerView.adapter = smallListAdapter
        binding.remoteUsersSmallRecyclerView.recycledViewPool.setMaxRecycledViews(0,0)

        setUpLocalVideo(binding.localUserVideoBigView)

        try{
            Picasso.get().load(callViewModel.myDetails?.image).into(binding.localUserVideoBigImageView)
            Picasso.get().load(callViewModel.myDetails?.image).into(binding.localUserVideoSmallImageView)
        }
        catch (_:Exception){}
    }

    private fun setUpLocalVideo(frameLayout: FrameLayout) {
        frameLayout.removeAllViews()
        val surfaceView = SurfaceView(callActivity.applicationContext)
        frameLayout.addView(surfaceView)
        agoraManager.setupLocalVideoView(surfaceView = surfaceView)
    }

    private fun setUpRemoteVideo(surfaceView: SurfaceView, uid: Int) {
//        frameLayout.removeAllViews()
//        val surfaceView = SurfaceView(callActivity.applicationContext)
        agoraManager.setupRemoteVideoView(surfaceView = surfaceView, uid = uid)
//        frameLayout.addView(surfaceView)
    }

    private fun setOnClickListeners() {

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

        binding.callControlView.btnMuteVideo.setOnClickListener {
            agoraManager.toggleVideoMute()
        }

        binding.callControlView.btnSwitchCamera.setOnClickListener {
            agoraManager.switchCamera()
        }

        binding.closeSelectedUserVideoButton.setOnClickListener {
            callViewModel.onRemoteUserSelected(null)
        }

    }

    private fun attachObservers() {
        initializeObservers()
        listenForCallControlUpdates()
        listenForCallState()
        listenForCallTime()
        listenForCallUser()
    }

    private fun initializeObservers(){

        selectedUserMicMuteObserver = Observer{ muted ->
            AppLogger.log("Selected user mic mute state observer called ===> $muted")
            binding.selectedUserMicOffIcon.visibility = if(muted) View.VISIBLE else View.GONE
        }

        selectedUserVideoMuteObserver = Observer{ muted ->
            AppLogger.log("Selected user video mute state observer called ===> $muted")
            if (muted){
                binding.selectedUserVideoOffIcon.visibility = View.VISIBLE
                binding.selectedUserImageView.visibility = View.VISIBLE
                binding.selectedUserVideoView.visibility = View.GONE
            }
            else{
                binding.selectedUserVideoOffIcon.visibility = View.GONE
                binding.selectedUserImageView.visibility = View.GONE
                binding.selectedUserVideoView.visibility = View.VISIBLE

                if(selectedUser != null){
                    setUpRemoteVideo(binding.selectedUserVideoView,selectedUser!!.remoteId)
                }

                smallListAdapter.hardRefresh()
            }

        }

    }

    private fun listenForCallControlUpdates() {
        AppLogger.log("Attaching call control observers in oto audio call fragment")
        // listening audio mute state and updating button icon and style
        callViewModel.audioMuted.observe(viewLifecycleOwner) { muted ->
            AppLogger.log("Audio mute observer called in group video call fragment ===> mute : $muted")
            // update local user state view visibility
            if (muted) {
                binding.callControlView.btnMuteAudio.setBackgroundResource(R.drawable.circle_white_background)
                binding.callControlView.btnMuteAudio.setImageResource(R.drawable.mic_off)
                binding.callControlView.btnMuteAudio.setColorFilter(
                    ContextCompat.getColor(
                        callActivity,
                        R.color.colorPrimary
                    ), PorterDuff.Mode.SRC_IN
                )
                binding.localUserVideoBigMicMuteIcon.visibility = View.VISIBLE
                binding.localUserVideoSmallMicMuteIcon.visibility = View.VISIBLE
            } else {
                binding.callControlView.btnMuteAudio.setBackgroundResource(R.drawable.circle_gray_background)
                binding.callControlView.btnMuteAudio.setImageResource(R.drawable.mic_on)
                binding.callControlView.btnMuteAudio.setColorFilter(
                    ContextCompat.getColor(
                        callActivity,
                        R.color.white
                    ), PorterDuff.Mode.SRC_IN
                )
                binding.localUserVideoBigMicMuteIcon.visibility = View.GONE
                binding.localUserVideoSmallMicMuteIcon.visibility = View.GONE
            }

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

        // listening video state and updating button icon and style
        callViewModel.videoMuted.observe(viewLifecycleOwner) { muted ->
            AppLogger.log("Audio mute observer called in group video call fragment ===> enabled : $muted")
            // update local user state view visibility
            if (muted) {
                binding.callControlView.btnMuteVideo.setBackgroundResource(R.drawable.circle_white_background)
                binding.callControlView.btnMuteVideo.setImageResource(R.drawable.video_off)
                binding.callControlView.btnMuteVideo.setColorFilter(
                    ContextCompat.getColor(
                        callActivity,
                        R.color.colorPrimary
                    ), PorterDuff.Mode.SRC_IN
                )
                binding.localUserVideoBigView.visibility = View.GONE
                binding.localUserVideoSmallView.visibility = View.GONE
                binding.localUserVideoBigImageView.visibility = View.VISIBLE
                binding.localUserVideoSmallImageView.visibility = View.VISIBLE
                binding.localUserVideoBigVideoMuteIcon.visibility = View.VISIBLE
                binding.localUserVideoSmallVideoMuteIcon.visibility = View.VISIBLE
            } else {
                binding.callControlView.btnMuteVideo.setBackgroundResource(R.drawable.circle_gray_background)
                binding.callControlView.btnMuteVideo.setImageResource(R.drawable.video_on)
                binding.callControlView.btnMuteVideo.setColorFilter(
                    ContextCompat.getColor(
                        callActivity,
                        R.color.white
                    ), PorterDuff.Mode.SRC_IN
                )
                binding.localUserVideoBigImageView.visibility = View.GONE
                binding.localUserVideoSmallImageView.visibility = View.GONE
                binding.localUserVideoBigVideoMuteIcon.visibility = View.GONE
                binding.localUserVideoSmallVideoMuteIcon.visibility = View.GONE
                binding.localUserVideoBigView.visibility = View.VISIBLE
                binding.localUserVideoSmallView.visibility = View.VISIBLE
            }
        }
    }

    private fun listenForCallState() {
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

        if (callViewModel.callState.value != CallState.CONNECTED && hours <= 0 && minutes <= 0 && seconds <= 0) {
            return
        }

        // building time string
        var timeString = ""

        if (hours > 0) {
            if (hours < 10) {
                timeString += "0"
            }
            timeString += "$hours : "
        }

        if (minutes < 10) {
            timeString += "0"
        }
        timeString += "$minutes : "

        if (seconds < 10) {
            timeString += "0"
        }
        timeString += seconds.toString()

        binding.callTime.text = timeString
    }

    private fun listenForCallUser() {
        callViewModel.callUsers.observe(viewLifecycleOwner) { callUsers ->
            AppLogger.log("Call users list observer called in group audio call ====> list size : ${callUsers.size}")
            if (callUsers != null) {
                if(selectedUser == null){
                    smallListAdapter.updateList(emptyList())
                    gridListAdapter.updateList(callUsers)
                }
                else{
                    gridListAdapter.updateList(emptyList())
                    smallListAdapter.updateList(callUsers)
                }
            }
        }

        callViewModel.selectedCallUser.observe(viewLifecycleOwner) { user ->

            AppLogger.log("Selected user observer called ===> user remote id : ${user?.remoteId}")

            selectedUser?.videoMuted?.removeObserver(selectedUserVideoMuteObserver)
            selectedUser?.micMuted?.removeObserver(selectedUserMicMuteObserver)
            selectedUser = null

            if (user != null) {

                selectedUser = user

                // hide big views
                binding.localUserVideoBigCardView.visibility = View.GONE
                binding.remoteUsersBigRecyclerView.visibility = View.GONE

                // show small views
                binding.selectedUserViewsContainer.visibility = View.VISIBLE
                binding.smallViewsContainer.visibility = View.VISIBLE

                // setup small and selected user videos
                setUpLocalVideo(binding.localUserVideoSmallView)
                setUpRemoteVideo(binding.selectedUserVideoView, uid = user.remoteId)

                selectedUser?.videoMuted?.observe(viewLifecycleOwner,selectedUserVideoMuteObserver)
                selectedUser?.micMuted?.observe(viewLifecycleOwner,selectedUserMicMuteObserver)


                try{
                    Picasso.get().load(user.participant?.image).into(binding.selectedUserImageView)
                }
                catch (_:Exception){}

            } else {
                // hide small views
                binding.selectedUserViewsContainer.visibility = View.GONE
                binding.smallViewsContainer.visibility = View.GONE

                // show big views
                binding.localUserVideoBigCardView.visibility = View.VISIBLE
                binding.remoteUsersBigRecyclerView.visibility = View.VISIBLE

                // setup big video for local user
                setUpLocalVideo(binding.localUserVideoBigView)
            }
        }
    }

    override fun onDestroyView() {
        callViewModel.audioMuted.removeObservers(viewLifecycleOwner)
        callViewModel.speakerEnabled.removeObservers(viewLifecycleOwner)
        callViewModel.videoMuted.removeObservers(viewLifecycleOwner)
        callViewModel.hours.removeObservers(viewLifecycleOwner)
        callViewModel.minutes.removeObservers(viewLifecycleOwner)
        callViewModel.seconds.removeObservers(viewLifecycleOwner)
        callViewModel.callState.removeObservers(viewLifecycleOwner)
        callViewModel.callUsers.removeObservers(viewLifecycleOwner)
        callViewModel.selectedCallUser.removeObservers(viewLifecycleOwner)
        super.onDestroyView()
    }

}