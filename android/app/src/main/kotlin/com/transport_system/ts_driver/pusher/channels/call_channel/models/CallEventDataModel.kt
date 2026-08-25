package com.transport_system.ts_driver.pusher.channels.call_channel.models

import com.google.gson.annotations.SerializedName

data class CallEventDataModel(
    @SerializedName("channelName")
    var channelName: String? = null,

    @SerializedName("conversationId")
    var conversationId: Int? = null,

    @SerializedName("conversationType")
    var conversationType: String? = null,

    @SerializedName("callType")
    var callType: String? = null
)
