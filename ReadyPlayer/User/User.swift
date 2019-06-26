//
//  User.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 15/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

class User: NSObject {
    typealias UserId = String
    
    // expose members to objc runtime for setValuesForKeys method in Room.swift when getting users in a room
    @objc var token: String?
    @objc var userId: String?
    @objc var userName: String?
}

extension User {
    
    static func getCurrentLoggedInUserKey() -> UserId {
        return Auth.auth().currentUser?.uid ?? ""
    }

}
