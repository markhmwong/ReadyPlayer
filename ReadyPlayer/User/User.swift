//
//  User.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 15/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

class User {
    typealias UserId = String
    
    var name: String?
    var userId: String?
}

extension User {
    
    static func getCurrentLoggedInUserKey() -> UserId {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
}
