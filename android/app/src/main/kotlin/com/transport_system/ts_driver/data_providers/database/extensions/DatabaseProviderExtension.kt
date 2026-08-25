package com.transport_system.ts_driver.data_providers.database.extensions

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import com.transport_system.ts_driver.data_providers.database.DatabaseManager


 fun getDatabase(context: Context): SQLiteDatabase? {
    val dbPath = context.getDatabasePath(DatabaseManager.CONVERSATIONS_DATABASE_NAME).absolutePath
    return try {
        SQLiteDatabase.openDatabase(dbPath, null, SQLiteDatabase.OPEN_READONLY)
    } catch (e: Exception) {
        e.printStackTrace()
        null
    }
}

