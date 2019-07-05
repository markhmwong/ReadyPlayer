//
//  MainViewModel.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 14/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

class MainViewModel {
    let ref = Database.database().reference(fromURL: "https://readyplayer-76fee.firebaseio.com/")
    
    var roomDataSource: [Room] = []
    
    var currentUser: User = User()
}
