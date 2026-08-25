package com.transport_system.ts_driver.data_providers.models.group

import com.google.gson.annotations.SerializedName
import com.transport_system.ts_driver.data_providers.models.common.ParticipantModel

data class GroupConversationModel(
    val id: Int?,
    val name: String?,
    val participants: List<ParticipantModel>?,
    @SerializedName("group_setting") val groupSettings: GroupSettingsModel?
)
