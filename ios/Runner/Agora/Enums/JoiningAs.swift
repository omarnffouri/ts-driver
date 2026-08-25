//
//  JoiningAs.swift
//  Runner
//
//  Created by Hashim Khan on 24/01/2024.
//

enum JoiningAs {
    case publisher
    case attendee
    
    
    // Method to get the name of the enum case as a string
    func getName() -> String {
        switch self {
        case .publisher:
            return "publisher"
        case .attendee:
            return "attendee"
        }
    }
}
