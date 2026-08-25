//
//  AppLogger.swift
//  Runner
//
//  Created by TMS on 03/02/2025.
//

import Foundation
import CoreLocation
import FirebaseDatabase


class AppLogger {
    
    static let shared = AppLogger()

    func log( message: String) {
        guard let myDetails = MyDetails.loadFromSharedPrefs() else {
            return
        }
        
        let dataToUpdate: [String: Any] = [
            "user_id": myDetails.userId ?? "",
            "timestamp": [".sv": "timestamp"],
            "message": message
        ]
        
        pushLog(myDetails: myDetails, data: dataToUpdate)
    }

    private func pushLog(myDetails: MyDetails, data: [String: Any]) {
        let root = MyDetails.isStaging() ? "call_logs_Staging" : "call_logs"

        let logsRef = Database.database().reference().child(root)
            .child(getCurrentDateInFormat())
            .child("\(myDetails.userId ?? 0)")

        logsRef.childByAutoId().setValue(data)
    }

    private func getCurrentDateInFormat() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: currentDate)
    }
}
