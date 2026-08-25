package com.transport_system.ts_driver.native_calling_plugin


import io.flutter.plugin.common.EventChannel
import io.flutter.embedding.engine.plugins.FlutterPlugin

class NativeCallingEventChannel : EventChannel.StreamHandler, FlutterPlugin {

    companion object {
        val instance: NativeCallingEventChannel by lazy { NativeCallingEventChannel() }
    }

    private var eventSink: EventChannel.EventSink? = null
    private var eventChannel: EventChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel = EventChannel(binding.binaryMessenger, "native_calling_event_channel")
        eventChannel?.setStreamHandler(instance)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        eventChannel?.setStreamHandler(null)
        eventChannel = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        this.eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        this.eventSink = null
    }

    fun sendEvent(event: NativeCallingEvents, data: Any?) {
        eventSink?.success(
            mapOf(
                "event" to event.getName(),
                "data" to data
            )
        )
    }
}
