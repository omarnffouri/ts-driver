package com.transport_system.ts_driver.native_calling_plugin

import android.content.Context
import com.transport_system.ts_driver.agora.AgoraManager
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastActions
import com.transport_system.ts_driver.broadcast_receiver.CallBroadcastReceiver
import com.transport_system.ts_driver.helpers.AppLogger
import com.transport_system.ts_driver.telecom.managers.CallManager
import com.transport_system.ts_driver.telecom.models.Call
import com.transport_system.ts_driver.telecom.models.CallPayload
import com.transport_system.ts_driver.telecom.service.CallConnection
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID

class NativeCallingMethodChannel : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {
        private const val CHANNEL_NAME = "native_calling_method_channel"
        var channel: MethodChannel? = null
    }

    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel?.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "place_call" -> {
                try {

                    if(context == null){
                        result.success(false)
                        AppLogger.log("context is null in place_call native method.")
                        return
                    }

                    @Suppress("UNCHECKED_CAST")
                    val arguments = call.arguments as? Map<String?, Any?> ?: run {
                        result.success(false)
                        AppLogger.log("Method arguments null on place_call native method")
                        return
                    }


                    val mappedArguments: Map<String?, Any?> = arguments
                        .filter { it.key != null && it.value != null }
                        .mapKeys { it.key as String }
                        .mapValues { it.value.toString() }

                    val callPayload = CallPayload.fromMap(mappedArguments)

                    val tempCallID = try {
                        UUID.fromString(callPayload.tempCallId)
                    } catch (e: Exception) {
                        result.success(false)
                        AppLogger.log("Exception while parsing uuid in place_call native method ===> ${e.message}")
                        return
                    }

                    CallManager(context = context!!).placeCall(call = Call(uuid = tempCallID, callPayload = callPayload, isOutGoing = true))

                    result.success(true)
                    return
                }
                catch (e:Exception){
                    AppLogger.log("Exception while placing call from a method channel ===> ${e.message}")
                    return result.success(false)
                }
            }

            "open_native_call_ui" -> {
                try {
                    val callId = call.arguments as String
                    val currentCall = AgoraManager.instance.callViewModel.currentCall.value
                    if (currentCall != null && context != null) {
                        if (currentCall.uuid.toString() == callId) {
                            AgoraManager.instance.launchCallScreen(
                                context = context!!,
                                callPayload = currentCall.callPayload
                            )
                             result.success(true)
                            return
                        }
                        else{
                            AppLogger.log("Current call id not matched with params call id in ===> open_native_call_ui")
                        }
                    }
                    else{
                        AppLogger.log("Current call or context is null in ===> open_native_call_ui")
                    }
                     result.success(false)
                    return
                } catch (e: Exception) {
                    AppLogger.log("Exception while opening a call screen in method channel ===> ${e.message}")
                     result.success(false)
                    return
                }

            }

            "end_call" -> {
                try {
                    val callId = call.arguments as String
                    val currentCall = AgoraManager.instance.callViewModel.currentCall.value
                    if (currentCall != null && context != null) {
                        if (currentCall.uuid.toString() == callId) {
                            context!!.sendBroadcast(
                                CallBroadcastReceiver.buildBroadcastIntent(
                                    context = context!!,
                                    action = CallBroadcastActions.ACTION_CALL_ENDED,
                                    data = currentCall.callPayload.toBundle()
                                )
                            )
                             result.success(true)
                            return
                        }
                        else{
                            AppLogger.log("Current call id not matched with params call id in ===> end_call")
                        }
                    }
                    else{
                        AppLogger.log("Current call or context is null in ===> end_call")
                    }
                     result.success(false)
                    return
                } catch (e: Exception) {
                    AppLogger.log("Exception while ending call from a method channel ===> ${e.message}")
                     result.success(false)
                    return
                }
            }

            "can_start_call" -> {
                 result.success(AgoraManager.instance.callViewModel.currentCall.value == null && CallConnection.currentConnection == null)
                return
            }


            "get_current_call" -> {
                 result.success(AgoraManager.instance.callViewModel.currentCall.value?.callPayload?.toMap())
                return
            }

            else -> {
                 result.notImplemented()
                return
            }
        }
    }


}
