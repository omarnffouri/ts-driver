package com.transport_system.ts_driver.data_providers.models.oto

import com.google.gson.annotations.SerializedName
import com.transport_system.ts_driver.data_providers.models.common.ParticipantModel

data class ConversationModel(
    val id: Int?,
    @SerializedName("receiver") val user: ConversationReceiverModel?,
    @SerializedName("date_time_in_humans") val dateTimeInHumans: String?,
    @SerializedName("chat_able") val chatAble: Boolean?,
    val participants: List<ParticipantModel>?,
)