//
//  ProfileViewModel.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 6/7/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

class ProfileViewModel {
    let ref = Database.database().reference(fromURL: "https://readyplayer-76fee.firebaseio.com/")
    
    let cellId = "settingsCellId"
    
    let dataSource = [
        ["Username", "UserId"],
    ]
    
    enum Sections: String, CaseIterable {
        case User = "User"
    }
    
    enum UserSettings: Int, CaseIterable {
        case Username
        case UserId
    }
}
