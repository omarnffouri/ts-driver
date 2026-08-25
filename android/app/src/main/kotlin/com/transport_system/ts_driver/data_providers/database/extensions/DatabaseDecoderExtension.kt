package com.transport_system.ts_driver.data_providers.database.extensions

import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.transport_system.ts_driver.data_providers.models.group.GroupConversationModel
import com.transport_system.ts_driver.data_providers.models.group.GroupSettingsModel
import com.transport_system.ts_driver.data_providers.models.oto.ConversationModel
import com.transport_system.ts_driver.helpers.AppLogger


fun decodeOtoConversation(jsonString: String): ConversationModel? {
    return try {
        val gson = Gson()
        gson.fromJson(jsonString, ConversationModel::class.java)
    } catch (e: Exception) {
        println("Error decoding conversation JSON: ${e.message}")
        null
    }
}



fun decodeGroupConversation(jsonString: String): GroupConversationModel? {
    try {
        val gson = Gson()
        return gson.fromJson(jsonString, GroupConversationModel::class.java)
    } catch (e: Exception) {
        AppLogger.log("Error decoding group conversation JSON ===> ${e.message}")
        return null
    }
}


fun decodeGroupSettings(jsonString: String): GroupSettingsModel? {
    return try {
        val gson = Gson()
        gson.fromJson(jsonString, GroupSettingsModel::class.java)
    } catch (e: Exception) {
        AppLogger.log("Error decoding group settings JSON: ${e.message}")
        null  // Return null if any exception occurs
    }
}