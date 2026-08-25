package com.transport_system.ts_driver.data_providers.database

import android.content.Context
import com.transport_system.ts_driver.data_providers.database.extensions.decodeGroupConversation
import com.transport_system.ts_driver.data_providers.database.extensions.decodeOtoConversation
import com.transport_system.ts_driver.data_providers.database.extensions.getDatabase
import com.transport_system.ts_driver.data_providers.models.group.GroupConversationModel
import com.transport_system.ts_driver.data_providers.models.oto.ConversationModel
import com.transport_system.ts_driver.helpers.AppLogger
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext


class DatabaseManager {

    companion object{
        val instance = DatabaseManager()

        // database names
        const val CONVERSATIONS_DATABASE_NAME = "conversations_database.db"

        //
        // table names
        const val OTO_CONVERSATIONS_TABLE_NAME = "conversations"
         const val GROUP_CONVERSATIONS_TABLE_NAME = "group_conversations"

    }

    //
    //
    //function to fetch the specific conversation with ID
    suspend fun fetchOtoConversation(conversationId: Int?, context: Context): ConversationModel? {
        if (conversationId == null) {
            AppLogger.log("nil conversationId passed in fetchOtoConversation")
            return null
        }
        return withContext(Dispatchers.IO){
            val db = getDatabase(context = context) ?: return@withContext null
             try {
                val query = "SELECT * FROM $OTO_CONVERSATIONS_TABLE_NAME WHERE conversation_id = ?;"
                val cursor = db.rawQuery(query, arrayOf(conversationId.toString())).use { cursor ->
                    var conversation: ConversationModel? = null
                    if (cursor.moveToFirst()) {
                        val conversationJsonString = cursor.getString(2)
                        conversation = conversationJsonString?.takeIf { it.isNotEmpty() }
                            ?.let { decodeOtoConversation(it) }
                    }
                    conversation
                }
                cursor
            } catch (e: Exception) {
                AppLogger.log("Error fetching OTO conversation ===> ${e.message}")
                null
            } finally {
                db.close()
            }
        }
    }


    //
    //
    // function to fetch the specific group contains a conversations ID
    suspend fun fetchGroupConversation(conversationId: Int?, context: Context): GroupConversationModel? {
        if (conversationId == null) {
            AppLogger.log("nil conversationId passed in fetchGroupDetails")
            return null
        }
        return withContext(Dispatchers.IO){
            val db = getDatabase(context = context) ?: return@withContext null
            var group: GroupConversationModel? = null
             try {
                db.rawQuery("SELECT * FROM $GROUP_CONVERSATIONS_TABLE_NAME", null).use { cursor ->
                    // Loop through the cursor rows
                    while (cursor.moveToNext()) {
                        try {
                            val conversationJsonString = cursor.getString(2)
                            val conversation = decodeGroupConversation(conversationJsonString)
                            if (conversation != null && conversation.id == conversationId) {
                               group = conversation
                                break
                            }
                        } catch (e: Exception) {
                            AppLogger.log("Error processing cursor row: ${e.message}")
                        }
                    }
                    group
                }
            }
            catch (e:Exception){
                AppLogger.log("Error during database query execution in fetchGroupDetails: ${e.message}")
                null
            }
            finally {
                try {
                    db.close()
                } catch (e: Exception) {
                    AppLogger.log("Error closing database in fetchGroupDetails: ${e.message}")
                }
            }
        }
    }

}