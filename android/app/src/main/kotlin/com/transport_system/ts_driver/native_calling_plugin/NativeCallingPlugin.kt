package com.transport_system.ts_driver.native_calling_plugin

import io.flutter.embedding.engine.plugins.FlutterPlugin

class NativeCallingPlugin : FlutterPlugin {

    private var methodChannel: NativeCallingMethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel = NativeCallingMethodChannel()
        methodChannel?.onAttachedToEngine(binding)
        NativeCallingEventChannel.instance.onAttachedToEngine(binding)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel?.onDetachedFromEngine(binding)
        methodChannel = null
        NativeCallingEventChannel.instance.onDetachedFromEngine(binding)
    }
}
