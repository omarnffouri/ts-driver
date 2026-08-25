package com.transport_system.ts_driver.data_providers.models.group


data class GroupSettingsModel(
    val id: Int?,
    val name: String?,
    val logo: String?
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as GroupSettingsModel

        if (id != other.id) return false
        if (name != other.name) return false
        if (logo != other.logo) return false

        return true
    }

    override fun hashCode(): Int {
        var result = id ?: 0
        result = 31 * result + (name?.hashCode() ?: 0)
        result = 31 * result + (logo?.hashCode() ?: 0)
        return result
    }
}
