package com.transport_system.ts_driver.fragments

import android.annotation.SuppressLint
import android.graphics.PorterDuff
import android.os.Bundle
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.SurfaceView
import android.view.View
import android.view.ViewGroup
import android.view.animation.AccelerateDecelerateInterpolator
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.constraintlayout.widget.ConstraintSet
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.transition.TransitionManager
import com.squareup.picasso.Picasso
import com.transport_system.ts_driver.R
import com.transport_system.ts_driver.activities.CallActivity
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.agora.enums.CallState
import com.transport_system.ts_driver.agora.models.CallUser
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.data_providers.models.common.ParticipantModel
import com.transport_system.ts_driver.databinding.FragmentOtoVideoCallBinding
import com.transport_system.ts_driver.helpers.AppLogger
import kotlin.math.abs
import kotlin.math.absoluteValue


class OtoVideoCallFragment(private val callActivity: CallActivity) : Fragment() {


    private lateinit var binding: FragmentOtoVideoCallBinding
    private val agoraManager = AgoraManager.instance
    private val callViewModel = agoraManager.callViewModel

    private var localSurfaceView : SurfaceView = SurfaceView(callActivity.applicationContext)
    private var remoteSurfaceView : SurfaceView = SurfaceView(callActivity.applicationContext)


    private val _otherUser = MutableLiveData<CallUser?>(null)
    private val otherUser: LiveData<CallUser?> get() = _otherUser
    private var me : ParticipantModel? = null

    private var isShowingControls = true
    private var isShowingRemote = true


    // display configs
    private val display = callActivity.resources.displayMetrics
    private val dp = display.density

    // screen width and height
    private val screenWidth = display.widthPixels
    private val screenHeight = display.heightPixels

    // smaller video view width and height
    private val smallVideoWidth = 100 * dp
    private val smallVideoHeight = 130 * dp

    // horizontal margins
    private val marginLeft = (16 * dp)
    private val marginRight = (16 * dp)

    // vertical margins
    private val marginTopMin = (48 * dp)
    private val marginTopMax = (126 * dp)
    private val marginBottomMin = (16 * dp)
    private val marginBottomMax = (90 * dp)

    // vertical bounds
    private val boundTop: Float get() = if (isShowingControls) marginTopMax else marginTopMin
    private val boundBottom: Float get() = (screenHeight - smallVideoHeight - (if (isShowingControls) marginBottomMax else marginBottomMin))

    // horizontal bounds
    private val boundLeft: Float get() = marginLeft
    private val boundRight: Float get() = (screenWidth - smallVideoWidth - marginRight)


    // nearest local video points
    private val closestLocalYBound: Float
        get() {
            val distanceToPoint1 = abs(localVideoPosition.y - boundTop)
            val distanceToPoint2 = abs(localVideoPosition.y - boundBottom)
            return if (distanceToPoint1 < distanceToPoint2) boundTop else boundBottom
        }


    // nearest local video points
    private val closestRemoteYBound: Float
        get() {
            val distanceToPoint1 = abs(remoteVideoPosition.y - boundTop)
            val distanceToPoint2 = abs(remoteVideoPosition.y - boundBottom)
            return if (distanceToPoint1 < distanceToPoint2) boundTop else boundBottom
        }


    // video positions
    private var localVideoPosition: Position = Position(
        x = (screenWidth - smallVideoWidth - marginRight),
        y = (screenHeight - smallVideoHeight - marginBottomMax)
    )
    private var remoteVideoPosition: Position =
        Position(x = marginLeft, y = (screenHeight - smallVideoHeight - marginBottomMax))


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        binding = FragmentOtoVideoCallBinding.inflate(inflater, container, false)
        loadData()
        setOnClickListeners()
        setDragListeners()
        attachObservers()
        return binding.root
    }

    private fun initializeVideoPositions() {
        binding.localVideoCardView.x = localVideoPosition.x
        binding.localVideoCardView.y = localVideoPosition.y
    }

    private fun loadData() {

        binding.callerName.text = callViewModel.getOppositeUser()?.name
        binding.callTime.text = callViewModel.callState.value?.getName()
        try {
            Picasso.get().load(callViewModel.getOppositeUser()?.image)
                .into(binding.callerImage)
        } catch (_: Exception) {
        }

         me = callViewModel.participants.value?.firstOrNull { it.pid == callViewModel.myPid.value }

        try {
            Picasso.get().load(me?.image)
                .into(binding.localUserImageView)
        } catch (_: Exception) {
        }

        remoteSurfaceView.setZOrderMediaOverlay(false)
        localSurfaceView.setZOrderMediaOverlay(true)
        initializeVideoPositions()
        setupLocalUserVideo()
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

        binding.remoteVideoCardView.setOnClickListener {
            if (isShowingRemote) {
                isShowingControls = if (isShowingControls) {
                    hideCallControlsAndInfoView()
                    false
                } else {
                    showCallControlsAndInfoView()
                    true
                }
            } else {
                animateRemoteVideoToBigger()
                isShowingRemote = true
            }
        }

        binding.localVideoCardView.setOnClickListener {
            if (isShowingRemote) {
                animateLocalVideoViewToBigger()
                isShowingRemote = false
            } else {
                isShowingControls = if (isShowingControls) {
                    hideCallControlsAndInfoView()
                    false
                } else {
                    showCallControlsAndInfoView()
                    true
                }
            }
        }

    }

    @SuppressLint("ClickableViewAccessibility")
    private fun setDragListeners() {

        binding.localVideoCardView.setOnTouchListener { view, event ->


            if(!isShowingRemote){
                view.performClick()
                return@setOnTouchListener false
            }

            when (event.action) {
                MotionEvent.ACTION_DOWN -> {

                    view.tag = Position(x = event.rawX, y = event.rawY)
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    try {
                        val startPosition = view.tag as Position
                        val newX = (view.x + (event.rawX - startPosition.x)).coerceIn(boundLeft, boundRight)
                        val newY = (view.y + (event.rawY - startPosition.y)).coerceIn(boundTop, boundBottom)

                        view.x = newX
                        view.y = newY

                        startPosition.x = event.rawX
                        startPosition.y = event.rawY
                    } catch (_: Exception) { }
                    true
                }

                MotionEvent.ACTION_UP -> {
                    try {
                        val dragPosition = view.tag as Position
                        var newX = (view.x + (event.rawX - dragPosition.x)).coerceIn(boundLeft, boundRight)
                        val newY = (view.y + (event.rawY - dragPosition.y)).coerceIn(boundTop, boundBottom)

                        val deltaX = newX - localVideoPosition.x
                        val deltaY = newY - localVideoPosition.y

                        newX = if(newX < (screenWidth / 2)) boundLeft else boundRight

                        localVideoPosition.x = newX
                        localVideoPosition.y = newY

                        binding.localVideoCardView.animate()
                            .x(newX)
                            .setDuration(300)
                            .setInterpolator(AccelerateDecelerateInterpolator())
                            .start()

                        val clickThreshold = 5 * dp
                        if (deltaX.absoluteValue < clickThreshold && deltaY.absoluteValue < clickThreshold) {
                            view.performClick()
                        }
                    } catch (_: Exception) { }
                    true
                }

                else -> false
            }
        }

        binding.remoteVideoCardView.setOnTouchListener { view, event ->

            if(isShowingRemote){
                view.performClick()
                return@setOnTouchListener false
            }

            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    view.tag = Position(x = event.rawX, y = event.rawY)
                    true
                }

                MotionEvent.ACTION_MOVE -> {
                    try {
                        val startPosition = view.tag as Position
                        val newX = (view.x + (event.rawX - startPosition.x)).coerceIn(boundLeft, boundRight)
                        val newY = (view.y + (event.rawY - startPosition.y)).coerceIn(boundTop, boundBottom)

                        view.x = newX
                        view.y = newY

                        startPosition.x = event.rawX
                        startPosition.y = event.rawY
                    } catch (_: Exception) { }
                    true
                }

                MotionEvent.ACTION_UP -> {
                    try {
                        val dragPosition = view.tag as Position
                        var newX = (view.x + (event.rawX - dragPosition.x)).coerceIn(boundLeft, boundRight)
                        val newY = (view.y + (event.rawY - dragPosition.y)).coerceIn(boundTop, boundBottom)

                        val deltaX = newX - remoteVideoPosition.x
                        val deltaY = newY - remoteVideoPosition.y

                        newX = if(newX < (screenWidth / 2)) boundLeft else boundRight

                        remoteVideoPosition.x = newX
                        remoteVideoPosition.y = newY

                        binding.remoteVideoCardView.animate()
                            .x(newX)
                            .setDuration(300)
                            .setInterpolator(AccelerateDecelerateInterpolator())
                            .start()

                        val clickThreshold = 5 * dp
                        if (deltaX.absoluteValue < clickThreshold && deltaY.absoluteValue < clickThreshold) {
                            view.performClick()
                        }
                    } catch (_: Exception) { }
                    true
                }

                else -> false
            }
        }
    }

    private fun animateLocalVideoViewToBigger() {
        val constraintSet = ConstraintSet()
        constraintSet.clone(binding.root)

        // Animate localeVideoCardView to full screen
        constraintSet.constrainWidth(binding.localVideoCardView.id, ConstraintLayout.LayoutParams.MATCH_PARENT)
        constraintSet.constrainHeight(binding.localVideoCardView.id, ConstraintLayout.LayoutParams.MATCH_PARENT)
        binding.localVideoCardView.setCardBackgroundColor(resources.getColor(android.R.color.transparent,null))
        binding.localVideoCardView.maxCardElevation = 0f
        binding.localVideoCardView.cardElevation = 0f
        binding.localVideoCardView.radius = 0f
        binding.localVideoView.elevation = 0f


        // Animate remoteVideoCardView to small view
        constraintSet.constrainWidth(binding.remoteVideoCardView.id, smallVideoWidth.toInt())
        constraintSet.constrainHeight(binding.remoteVideoCardView.id, smallVideoHeight.toInt())
        binding.remoteVideoCardView.setCardBackgroundColor(resources.getColor(R.color.gray,null))
        binding.remoteVideoCardView.maxCardElevation = 10 * dp
        binding.remoteVideoCardView.cardElevation = 10 * dp
        binding.remoteVideoCardView.radius = 10 * dp
        binding.remoteVideoView.elevation = 10 * dp




        // Animate the remote user image view size to small
        val remoteImageParams = binding.remoteUserImageView.layoutParams
        remoteImageParams.width = (40 * dp).toInt()
        remoteImageParams.height = (40 * dp).toInt()
        binding.remoteUserImageView.layoutParams = remoteImageParams


        // Animate the local user image view size to bigger
        val localImageParams = binding.localUserImageView.layoutParams
        localImageParams.width = (120 * dp).toInt()
        localImageParams.height = (120 * dp).toInt()
        binding.localUserImageView.layoutParams = localImageParams


        // Animate the changes
        TransitionManager.beginDelayedTransition(binding.root)
        constraintSet.applyTo(binding.root)

        // set local video position
        binding.localVideoCardView.animate().x(0f).y(0f).setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        // set remote video position
        binding.remoteVideoCardView.animate().x(remoteVideoPosition.x).y(closestRemoteYBound)
            .setDuration(300).setInterpolator(AccelerateDecelerateInterpolator())
            .start()


        localSurfaceView.setZOrderMediaOverlay(false)
        remoteSurfaceView.setZOrderMediaOverlay(true)

    }

    private fun animateRemoteVideoToBigger() {
        val constraintSet = ConstraintSet()
        constraintSet.clone(binding.root)

        // Animate remoteVideoCardView to full screen
        constraintSet.constrainWidth(binding.remoteVideoCardView.id, ConstraintLayout.LayoutParams.MATCH_PARENT)
        constraintSet.constrainHeight(binding.remoteVideoCardView.id, ConstraintLayout.LayoutParams.MATCH_PARENT)
        binding.remoteVideoCardView.setCardBackgroundColor(resources.getColor(android.R.color.transparent,null))
        binding.remoteVideoCardView.maxCardElevation = 0f
        binding.remoteVideoCardView.cardElevation = 0f
        binding.remoteVideoCardView.radius = 0f
        binding.remoteVideoView.elevation = 0f


        // Animate localeVideoCardView to small view
        constraintSet.constrainWidth(binding.localVideoCardView.id, smallVideoWidth.toInt())
        constraintSet.constrainHeight(binding.localVideoCardView.id, smallVideoHeight.toInt())
        binding.localVideoCardView.setCardBackgroundColor(resources.getColor(R.color.gray,null))
        binding.localVideoCardView.maxCardElevation = 10 * dp
        binding.localVideoCardView.cardElevation = 10 * dp
        binding.localVideoCardView.radius = 10 * dp
        binding.localVideoView.elevation = 10 * dp



        // Animate the local user image view size to small
        val localImageParams = binding.localUserImageView.layoutParams
        localImageParams.width = (40 * dp).toInt()
        localImageParams.height = (40 * dp).toInt()
        binding.localUserImageView.layoutParams = localImageParams


        // Animate the remote user image view size to bigger
        val remoteImageParams = binding.remoteUserImageView.layoutParams
        remoteImageParams.width = (120 * dp).toInt()
        remoteImageParams.height = (120 * dp).toInt()
        binding.remoteUserImageView.layoutParams = remoteImageParams


        // Animate the changes
        TransitionManager.beginDelayedTransition(binding.root)
        constraintSet.applyTo(binding.root)


        // set remote video position
        binding.remoteVideoCardView.animate().x(0f).y(0f).setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        // set local video position
        binding.localVideoCardView.animate().x(localVideoPosition.x).y(closestLocalYBound)
            .setDuration(300).setInterpolator(AccelerateDecelerateInterpolator())
            .start()

        remoteSurfaceView.setZOrderMediaOverlay(false)
        localSurfaceView.setZOrderMediaOverlay(true)
    }

    private fun attachObservers() {
        listenForCallControlUpdates()
        listenForCallState()
        listenForCallTime()
        listenForCallUserStates()
    }

    private fun listenForCallControlUpdates() {
        AppLogger.log("Attaching call control observers in oto audio call fragment")
        // listening audio mute state and updating button icon and style
        callViewModel.audioMuted.observe(viewLifecycleOwner) { muted ->
            AppLogger.log("Audio mute observer called in oto video call fragment ===> mute : $muted")
            binding.callControlView.btnMuteAudio.setBackgroundResource(if (muted) R.drawable.circle_white_background else R.drawable.circle_gray_background)
            binding.callControlView.btnMuteAudio.setImageResource(if (muted) R.drawable.mic_off else R.drawable.mic_on)
            binding.callControlView.btnMuteAudio.setColorFilter(
                ContextCompat.getColor(
                    callActivity, if (muted) R.color.colorPrimary else R.color.white
                ), PorterDuff.Mode.SRC_IN
            )
            binding.localUserMicOffIcon.visibility  = if(muted) View.VISIBLE else View.GONE
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
            AppLogger.log("Audio mute observer called in oto video call fragment ===> enabled : $muted")
            binding.callControlView.btnMuteVideo.setBackgroundResource(if (muted) R.drawable.circle_white_background else R.drawable.circle_gray_background)
            binding.callControlView.btnMuteVideo.setImageResource(if (muted) R.drawable.video_off else R.drawable.video_on)
            binding.callControlView.btnMuteVideo.setColorFilter(
                ContextCompat.getColor(
                    callActivity, if (muted) R.color.colorPrimary else R.color.white
                ), PorterDuff.Mode.SRC_IN
            )
            binding.localVideoView.visibility = if(muted) View.GONE else View.VISIBLE
            binding.localUserVideoOffIcon.visibility  =  if(muted) View.VISIBLE else View.GONE
            binding.localUserImageView.visibility  = if(muted) View.VISIBLE else View.GONE
        }
    }

    private fun listenForCallUserStates() {

        callViewModel.callUsers.observe(viewLifecycleOwner) { callUsers ->
            AppLogger.log("Call users list observer called in oto video called ====> list size : ${callUsers.size}")
            if (!callUsers.isNullOrEmpty() && otherUser.value == null) {

                val user = callUsers.firstOrNull { it.remoteId != callViewModel.myPid.value }
                    ?: return@observe

                _otherUser.value = user

                try {
                    Picasso.get().load(user.participant?.image).into(binding.remoteUserImageView)
                }
                catch (_:Exception){}

                binding.remoteVideoView.removeAllViews()
                remoteSurfaceView.z = 0f
                agoraManager.setupRemoteVideoView(surfaceView = remoteSurfaceView, uid = user.remoteId)
                binding.remoteVideoView.addView(remoteSurfaceView)
                listenForOtherUserStates()
            }
        }
    }

    private fun listenForOtherUserStates(){
        otherUser.value?.videoMuted?.observe(viewLifecycleOwner){ muted ->
            binding.remoteVideoView.visibility = if(muted) View.GONE else View.VISIBLE
            binding.remoteUserVideoOffIcon.visibility  =  if(muted) View.VISIBLE else View.GONE
            binding.remoteUserImageView.visibility  = if(muted) View.VISIBLE else View.GONE
        }
        otherUser.value?.micMuted?.observe(viewLifecycleOwner){ muted ->
            binding.remoteUserMicOffIcon.visibility  = if(muted) View.VISIBLE else View.GONE
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

    private fun setupLocalUserVideo() {
        binding.localVideoView.removeAllViews()
        localSurfaceView.z = 1f
        agoraManager.setupLocalVideoView(surfaceView = localSurfaceView)
        binding.localVideoView.addView(localSurfaceView)
    }

    private fun hideCallControlsAndInfoView() {
        binding.callInfoView.animate().y(-300f).setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        binding.callControlCardView.animate().y(screenHeight + 300f).setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        isShowingControls = false

        if(isShowingRemote){
            binding.localVideoCardView.animate().y(closestLocalYBound).setDuration(300)
                .setInterpolator(AccelerateDecelerateInterpolator()).start()
        }
        else{
            binding.remoteVideoCardView.animate().y(closestRemoteYBound).setDuration(300)
                .setInterpolator(AccelerateDecelerateInterpolator()).start()
        }
    }

    private fun showCallControlsAndInfoView() {
        binding.callInfoView.animate().y(marginTopMin).setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        binding.callControlCardView.animate().y(screenHeight - marginBottomMax + (16 * dp))
            .setDuration(300)
            .setInterpolator(AccelerateDecelerateInterpolator()).start()

        isShowingControls = true

        if(isShowingRemote){
            binding.localVideoCardView.animate().y(closestLocalYBound).setDuration(300)
                .setInterpolator(AccelerateDecelerateInterpolator()).start()
        }
        else{
            binding.remoteVideoCardView.animate().y(closestRemoteYBound).setDuration(300)
                .setInterpolator(AccelerateDecelerateInterpolator()).start()
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
        otherUser.value?.videoMuted?.removeObservers(viewLifecycleOwner)
        otherUser.value?.micMuted?.removeObservers(viewLifecycleOwner)
        super.onDestroyView()
    }

}