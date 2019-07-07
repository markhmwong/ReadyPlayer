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
    var state: Bool?
}

extension User {
    
    // get user from keychain
    
    static func getCurrentLoggedInUserKey() -> UserId {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    static func updateUserName(ref: DatabaseReference, userId: String, userName: String) -> Void {
        let userRef = ref.child("\(DatabaseReferenceKeys.users.rawValue)/\(User.getCurrentLoggedInUserKey())")
        userRef.updateChildValues(["userName" : userName]) { (err, ref) in
            if (err != nil) {
                print("Error updating username")
                return
            }
        }
    }
}
