package com.transport_system.ts_driver.agora.models

import com.google.gson.annotations.SerializedName

data class StartCallRecordingResponseModel(
    @SerializedName("cname") val cname: String?,
    @SerializedName("uid") val uid: String?,
    @SerializedName("resourceId") val resourceId: String?,
    @SerializedName("sid") val sid: String?
)
