package com.transport_system.ts_driver.data_providers.models.oto

import com.google.gson.annotations.SerializedName


data class ConversationReceiverModel(
    val id: Int?,
    val phone: String?,
    val name: String?,
    val image: String?,
    @SerializedName("model_type") val modelType: String?
)