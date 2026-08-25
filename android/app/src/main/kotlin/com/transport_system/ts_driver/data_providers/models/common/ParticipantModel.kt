package com.transport_system.ts_driver.data_providers.models.common

import com.google.gson.annotations.SerializedName

data class ParticipantModel(
    val id: Int?,
    @SerializedName("p_id") val pid: Int?,
    val name: String?,
    val phone: String?,
    val image: String?,
    @SerializedName("model_type") val modelType: String?,
    @SerializedName("is_group_admin") val isGroupAdmin: Boolean?,
    @SerializedName("user_designation") val userDesignation: String?
) {
    // Custom equality check
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ParticipantModel) return false
        return id == other.id && pid == other.pid && modelType == other.modelType
    }

    // Custom hash code generation
    override fun hashCode(): Int {
        var result = id ?: 0
        result = 31 * result + (pid ?: 0)
        result = 31 * result + (modelType?.hashCode() ?: 0)
        return result
    }
}
