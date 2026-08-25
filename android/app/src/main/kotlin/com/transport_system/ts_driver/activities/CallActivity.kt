package com.transport_system.ts_driver.activities

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.databinding.ActivityCallBinding
import com.transport_system.ts_driver.fragments.GroupAudioCallFragment
import com.transport_system.ts_driver.fragments.GroupVideoCallFragment
import com.transport_system.ts_driver.fragments.OtoAudioCallFragment
import com.transport_system.ts_driver.fragments.OtoVideoCallFragment
import com.transport_system.ts_driver.fragments.RingingFragment
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.telecom.models.CallPayload

class CallActivity : AppCompatActivity() {


    private lateinit var binding: ActivityCallBinding
    private val agoraManager = AgoraManager.instance
    val callViewModel = agoraManager.callViewModel

    companion object {

        private const val FROM_INCOMING_CALL_NOTIFICATION = "from_incoming_call_notification"
        private const val FROM_CALL_ACCEPT = "from_call_accept"
        private const val REQUEST_PERMISSIONS = "request_call_permissions"
        private const val CALL_PAYLOAD = "call_payload"
        private const val CALL_PERMISSION_REQUEST = 7341


        // Explicit component: with dev/staging/prod installed side by side, an
        // action-string intent resolves to every flavor and Android shows the
        // app chooser mid-call.
        fun getIntent(
            context: Context,
            data: Bundle,
            forIncomingCallNotification: Boolean,
            fromCallAccept: Boolean,
            requestPermissions: Boolean = false,
        ) =
            Intent(context, CallActivity::class.java).apply {
                putExtra(CALL_PAYLOAD, data)
                putExtra(FROM_INCOMING_CALL_NOTIFICATION, forIncomingCallNotification)
                putExtra(FROM_CALL_ACCEPT, fromCallAccept)
                putExtra(REQUEST_PERMISSIONS, requestPermissions)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
    }


    @SuppressLint("CommitTransaction", "WrongConstant")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityCallBinding.inflate(layoutInflater)
        setContentView(binding.root)


        try {
            @Suppress("DEPRECATION")
            window.addFlags(
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD or
                        WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                        WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                        WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS
            )
        }
        catch (_:Exception){}

        val callPayload: Bundle? = intent.getBundleExtra(CALL_PAYLOAD)
        if (callPayload == null) {
            finishThis()
            return
        }



        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            setTurnScreenOn(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
            @Suppress("DEPRECATION") window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
            @Suppress("DEPRECATION") window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
        }



        listenForCallUpdates()


        if (intent.getBooleanExtra(FROM_INCOMING_CALL_NOTIFICATION, false)) {
            AppLogger.log("Replace and load call ringing fragment in on create")
            loadFragment(RingingFragment(callActivity = this))
        } else if (intent.getBooleanExtra(REQUEST_PERMISSIONS, false)) {
            // Incoming call accepted: acquire mic/camera before joining Agora.
            ensureCallPermissionsThenStart()
        } else {
            loadCallFragment()
        }

    }


    @SuppressLint("MissingSuperCall", "CommitTransaction")
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        AppLogger.log("Activity tried to start again")

        if (intent.getBooleanExtra(FROM_CALL_ACCEPT, false)) {
            val callBundle = intent.getBundleExtra(CALL_PAYLOAD) ?: return
            val callPayload = CallPayload.fromBundle(callBundle)
            val callId = callPayload.tempCallId ?: return

            if (callId == callViewModel.currentCall.value?.uuid.toString()) {

                if (!callViewModel.currentCall.hasActiveObservers()) {
                    AppLogger.log("Don't have any active listener for call updated, attaching listener")
                    listenForCallUpdates()
                }

                if (intent.getBooleanExtra(REQUEST_PERMISSIONS, false)) {
                    // Incoming call accepted: acquire mic/camera before joining.
                    ensureCallPermissionsThenStart()
                } else {
                    loadCallFragment()
                }
            }

        }

    }


    private fun listenForCallUpdates() {
        callViewModel.currentCall.observe(this) { callPayload ->
            if (callPayload == null) {
                finishThis()
            }
        }
    }


    private fun finishThis() {
        if (!isFinishing) {
            finish()
        }
    }


    override fun onDestroy() {
        super.onDestroy()
        callViewModel.currentCall.removeObservers(this)
    }


    private fun loadFragment(fragment: Fragment) {
        supportFragmentManager.beginTransaction()
            .replace(binding.fragmentContainerView.id, fragment)
            .commit()
    }

    private fun loadCallFragment() {
        val callPayload = callViewModel.currentCall.value?.callPayload
        val isVideo = callPayload?.callType == "video"
        val isOto = callPayload?.conversationType == "oto"
        loadFragment(
            when {
                isVideo && isOto -> OtoVideoCallFragment(callActivity = this)
                isVideo -> GroupVideoCallFragment(callActivity = this)
                isOto -> OtoAudioCallFragment(callActivity = this)
                else -> GroupAudioCallFragment(callActivity = this)
            }
        )
    }

    private fun isVideoCall(): Boolean =
        callViewModel.currentCall.value?.callPayload?.callType == "video"

    private fun missingCallPermissions(): List<String> {
        val needed = mutableListOf(Manifest.permission.RECORD_AUDIO)
        if (isVideoCall()) needed.add(Manifest.permission.CAMERA)
        return needed.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
    }

    // Mic required; camera only for video. Explain, then join only after the result.
    private fun ensureCallPermissionsThenStart() {
        val missing = missingCallPermissions()
        if (missing.isEmpty()) {
            startAcceptedCall(cameraGranted = true)
            return
        }
        AlertDialog.Builder(this)
            .setTitle("Permission needed")
            .setMessage(
                if (isVideoCall())
                    "Allow microphone and camera to take this video call. Without the camera the call continues with audio only."
                else
                    "Allow microphone access to take this call."
            )
            .setCancelable(false)
            .setPositiveButton("Continue") { dialog, _ ->
                dialog.dismiss()
                ActivityCompat.requestPermissions(
                    this, missing.toTypedArray(), CALL_PERMISSION_REQUEST
                )
            }
            .setNegativeButton("Decline") { dialog, _ ->
                dialog.dismiss()
                endAcceptedCall("Microphone permission is required to take calls.")
            }
            .show()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != CALL_PERMISSION_REQUEST) return

        val micGranted = ContextCompat.checkSelfPermission(
            this, Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
        if (!micGranted) {
            endAcceptedCall("Microphone permission is required to take calls.")
            return
        }

        val cameraGranted = ContextCompat.checkSelfPermission(
            this, Manifest.permission.CAMERA
        ) == PackageManager.PERMISSION_GRANTED
        startAcceptedCall(cameraGranted = cameraGranted)
    }

    // joinAcceptedCall may flip callType to audio (camera denied); load the fragment after.
    private fun startAcceptedCall(cameraGranted: Boolean) {
        AgoraManager.instance.joinAcceptedCall(
            context = applicationContext, cameraGranted = cameraGranted
        )
        loadCallFragment()
    }

    private fun endAcceptedCall(reason: String) {
        Toast.makeText(this, reason, Toast.LENGTH_LONG).show()
        // Decline (hits call-declined API): no "accepted" was emitted, so nothing to end.
        callViewModel.currentCall.value?.callPayload?.let { callPayload ->
            sendBroadcast(
                CallBroadcastReceiver.buildBroadcastIntent(
                    context = applicationContext,
                    action = CallBroadcastActions.ACTION_CALL_INCOMING_DECLINE,
                    data = callPayload.toBundle()
                )
            )
        }
        finishThis()
    }

}