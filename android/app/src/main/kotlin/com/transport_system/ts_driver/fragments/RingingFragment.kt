package com.transport_system.ts_driver.fragments

import android.os.Bundle
import androidx.fragment.app.Fragment
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Toast
import com.bumptech.glide.Glide
import com.transport_system.ts_driver.R
import com.ncorti.slidetoact.SlideToActView
import com.transport_system.ts_driver.activities.CallActivity
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.databinding.FragmentRingingBinding

class RingingFragment(private val callActivity: CallActivity) : Fragment() {


    private lateinit var binding: FragmentRingingBinding


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?
    ): View {
        binding = FragmentRingingBinding.inflate(inflater, container, false)
        loadCallerDetails()
        setClickListeners()
        return binding.root
    }


    private fun loadCallerDetails() {
        binding.apply {

            val callPayload = callActivity.callViewModel.currentCall.value?.callPayload ?: return@apply

            // setting name to view
            callerName.text = callPayload.callerName

            //
            // setting call type to view
            callType.text = if (callPayload.callType == "audio") {
                if (callPayload.conversationType == "oto") {
                    "Audio"
                } else {
                    "Audio (Group)"
                }
            } else {
                if (callPayload.conversationType == "oto") {
                    "Video"
                } else {
                    "Video (Group)"
                }
            }


            //
            // setting image to view
            try {
                Glide.with(callActivity).load(callPayload.callerImage)
                    .placeholder(R.mipmap.ic_launcher).into(callerImage)
            } catch (_: Exception) {
            }
        }
    }


    private fun setClickListeners() {
        binding.apply {
            acceptButton.onSlideCompleteListener = object : SlideToActView.OnSlideCompleteListener {
                override fun onSlideComplete(view: SlideToActView) {
                    try {
                        val bundle = callActivity.callViewModel.currentCall.value?.callPayload?.toBundle()
                        if (bundle != null) {
                            callActivity.sendBroadcast(
                                CallBroadcastReceiver.buildBroadcastIntent(
                                    context = callActivity,
                                    action = CallBroadcastActions.ACTION_CALL_INCOMING_ACCEPT,
                                    data = bundle
                                )
                            )
                        } else {
                            Toast.makeText(
                                callActivity.applicationContext,
                                "Unable to receive a call.",
                                Toast.LENGTH_LONG
                            ).show()
                            callActivity.finish()
                        }
                    } catch (_: Exception) {
                        Toast.makeText(
                            callActivity.applicationContext,
                            "Unable to receive a call.",
                            Toast.LENGTH_LONG
                        ).show()
                        callActivity.finish()
                    }
                }
            }

            declineButton.onSlideCompleteListener =
                object : SlideToActView.OnSlideCompleteListener {
                    override fun onSlideComplete(view: SlideToActView) {
                        try {
                            val bundle = callActivity.callViewModel.currentCall.value?.callPayload?.toBundle()
                            if (bundle != null) {
                                callActivity.sendBroadcast(
                                    CallBroadcastReceiver.buildBroadcastIntent(
                                        context = callActivity,
                                        action = CallBroadcastActions.ACTION_CALL_INCOMING_DECLINE,
                                        data = bundle
                                    )
                                )
                            } else {
                                Toast.makeText(
                                    callActivity.applicationContext,
                                    "Unable to decline a call.",
                                    Toast.LENGTH_LONG
                                ).show()
                                callActivity.finish()
                            }
                        } catch (_: Exception) {
                            Toast.makeText(
                                callActivity.applicationContext,
                                "Unable to decline a call.",
                                Toast.LENGTH_LONG
                            ).show()
                            callActivity.finish()
                        }
                    }
                }
        }
    }

}