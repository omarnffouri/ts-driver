//
//  DatabasePathFinderExtensions.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

extension DatabaseManager {
    
    //
    // function to get the conversations DB path
    func getConversationsDatabasePath() -> String? {
        guard let documentDirectory = getDocumentDirectorPath() else{
            return nil
        }
        return documentDirectory.appendingPathComponent(DatabaseManager.ConversationsDatabaseName).path
    }

    
    
    //
    // function to get the Documents directory URL in system
    func getDocumentDirectorPath() -> URL? {
         let  directories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        if(directories.isEmpty){
            return nil
        }
        return directories.first
    }


}
