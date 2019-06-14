//
//  Room.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 14/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

struct Room {
    var id: String
    var name: String
}

extension Room {
    
    static func createRoom(databaseRef: DatabaseReference, name: String) {
        let refRooms = databaseRef.child("rooms")
        let newRoom = refRooms.childByAutoId()
        
        let data = ["id" : newRoom.key, "name" : name]
        
        newRoom.setValue(data) { (err, ref) in
            if err != nil {
                print("room error")
            }
            
            print("room created")
        }
    }    
}
