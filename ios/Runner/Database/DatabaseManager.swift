//
//  DatabaseManager.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

import SQLite3
import Foundation
// import sqflite

class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    //
    // database names
    static let ConversationsDatabaseName = "conversations_database.db"
    
    //
    // table names
    static let OtoConversationsTableName = "conversations"
    static let GroupConversationsTableName = "group_conversations"
    
    
    
    
    //
    //
    // function to fetch the specific conversation with ID
    func fetchOtoConversation(conversationId: Int?) throws -> ConversationModel?  {
        
        guard let conversationId = conversationId else {
            print("nil conversationId passed in fetchOtoConversation")
            return nil
        }
        
        guard let dbPath = getConversationsDatabasePath() else {
            print("Empty Database Path")
            return nil
        }
        
        var db: OpaquePointer?
        
        if (sqlite3_open(dbPath, &db) != SQLITE_OK) {
            print("Error opening database")
            return nil
        }
        
        defer {
            sqlite3_close(db)
        }
        
        let query = "SELECT * FROM \(DatabaseManager.OtoConversationsTableName) WHERE conversation_id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing query: \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
        
        sqlite3_bind_int64(statement, 1, sqlite3_int64(conversationId))
        
        var conversation: ConversationModel? = nil
        
        if sqlite3_step(statement) == SQLITE_ROW {
            if let conversationJsonString = extractJsonString(from: statement, at: 2) {
                conversation = decodeOtoConversation(from: conversationJsonString)
            }
        }
        
        sqlite3_finalize(statement)
        
        return conversation
    }
    
    
    
    //
    //
    // function to fetch the specific group contains a conversations ID
    func fetchGroupConversation(conversationId: Int?) throws -> GroupConversationModel?  {
        
        guard let conversationId = conversationId else {
            print("nil conversationId passed in fetchGroupInnerConversation")
            return nil
        }
        
        guard let dbPath = getConversationsDatabasePath() else {
            print("Empty Database Path")
            return nil
        }
        
        var db: OpaquePointer?
        
        if (sqlite3_open(dbPath, &db) != SQLITE_OK) {
            print("Error opening database")
            return nil
        }
        
        defer {
            sqlite3_close(db)
        }
        
        let query = "SELECT * FROM \(DatabaseManager.GroupConversationsTableName);"
        var statement: OpaquePointer?
        
        
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            print("Error preparing query: \(String(cString: sqlite3_errmsg(db)))")
            return nil
        }
                
        var group: GroupConversationModel? = nil
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let conversationsJsonString = extractJsonString(from: statement, at: 2),
               let conversation = decodeGroupConversations(from: conversationsJsonString),
               conversation.id == conversationId {
                group = conversation
                break
            }
        }
        
        sqlite3_finalize(statement)
        
        return group
    }
    
    
    
    
    
    
}
