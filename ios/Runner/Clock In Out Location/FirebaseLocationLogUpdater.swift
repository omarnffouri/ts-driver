//
//  FirebaseLocationLogUpdater.swift
//  Runner
//
//  Created by Hashim Khan on 14/11/2024.
//


import Foundation
import CoreLocation
import FirebaseDatabase


class FirebaseLocationLogUpdater {

    func updateLocationInFirebase( location: CLLocation,  fromGeofence:Bool = false) {
        guard let myDetails = MyDetails.loadFromSharedPrefs(),
              let clockInOutSession = ClockInOutSession.loadFromSharedPrefs() else {
            return
        }
        
        let firstName :String = myDetails.firstName ?? ""
        let lastName :String = myDetails.lastName ?? ""

        let dataToUpdate: [String: Any] = [
            "user_id": myDetails.userId ?? "",
            "timestamp": [".sv": "timestamp"],
            "name": "\(firstName) \(lastName)",
            "lat": location.coordinate.latitude,
            "lng": location.coordinate.longitude,
            "fromGeofence" : fromGeofence
        ]
        
        

        updateLocationLog(myDetails: myDetails, clockInOutSession: clockInOutSession, data: dataToUpdate)
        updateLiveLocation(myDetails: myDetails, clockInOutSession: clockInOutSession, data: dataToUpdate)
    }

    private func updateLiveLocation(myDetails: MyDetails, clockInOutSession: ClockInOutSession, data: [String: Any]) {
        let root = clockInOutSession.isStagingServer == true ? "user_tracking_live_Staging" : "user_tracking_live"

        let liveRef = Database.database().reference().child(root)
            .child(getCurrentDateInFormat())
            .child("\(myDetails.userId ?? 0)")

        liveRef.getData(completion: { error ,snapshot  in
            if ((snapshot?.exists()) != nil), let snapValue = snapshot?.value as? [String: Any], let firstKey = snapValue.keys.first {
                if firstKey == clockInOutSession.sessionId {
                    liveRef.child(clockInOutSession.sessionId ?? "session_error_ios").updateChildValues(data)
                } else {
                    liveRef.removeValue()
                    liveRef.child(clockInOutSession.sessionId ?? "session_error_ios").setValue(data)
                }
            } else {
                liveRef.child(clockInOutSession.sessionId ?? "session_error_ios").setValue(data)
            }
        })
    }

    private func updateLocationLog(myDetails: MyDetails, clockInOutSession: ClockInOutSession, data: [String: Any]) {
        let root = clockInOutSession.isStagingServer == true ? "user_tracking_logs_Staging" : "user_tracking_logs"

        let logsRef = Database.database().reference().child(root)
            .child(getCurrentDateInFormat())
            .child("\(myDetails.userId ?? 0)")
            .child(clockInOutSession.sessionId ?? "")

        logsRef.childByAutoId().setValue(data)
    }

    private func getCurrentDateInFormat() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: currentDate)
    }
}
