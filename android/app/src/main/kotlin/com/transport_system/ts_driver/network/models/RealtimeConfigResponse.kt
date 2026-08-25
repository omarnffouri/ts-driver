package com.transport_system.ts_driver.network.models

import com.google.gson.annotations.SerializedName

// Mirrors GET drivers/realtime-configuration. Only the fields the native call
// layer needs to refresh are modelled (websocket connection + agora app id);
// the server's agora secrets are intentionally not pulled into native.
data class RealtimeConfigResponse(
    val data: RealtimeConfigData?
)

data class RealtimeConfigData(
    val websocket: WebsocketConfig?,
    val agora: AgoraConfig?,
    @SerializedName("config_version") val configVersion: String?
)

data class WebsocketConfig(
    val key: String?,
    val host: String?,
    val port: Int?,
    @SerializedName("auth_endpoint") val authEndpoint: String?
)

data class AgoraConfig(
    @SerializedName("app_id") val appId: String?
)
