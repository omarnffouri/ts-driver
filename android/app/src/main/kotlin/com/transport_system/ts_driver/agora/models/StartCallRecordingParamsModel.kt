package com.transport_system.ts_driver.agora.models

import com.google.gson.annotations.SerializedName

data class StartCallRecordingParamsModel(
    @SerializedName("messageId") val messageId: Int,
    @SerializedName("channelName") val channelName: String,
    @SerializedName("uid") val uid: Int
)
