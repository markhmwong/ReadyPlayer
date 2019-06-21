//
//  Room.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 14/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation
import Firebase

class Room: NSObject {
    var id: String?
    var creator: String?
    var inviteLink: String?
    var name: String?
    
    static var awaitRoom = DispatchGroup()

    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.creator = dictionary["creator"] as? String
        self.inviteLink = dictionary["inviteLink"] as? String
        self.name = dictionary["name"] as? String
    }
}

extension Room {
    
    static func createRoom(ref: DatabaseReference, name: String, creatorId: String, completionHandler: @escaping () -> Void) -> Void {
        let refRooms = ref.child(DatabaseReferenceKeys.rooms.rawValue)
        let newRoom = refRooms.childByAutoId()
        
        let data = ["id" : newRoom.key, "name" : name, "inviteLink" : newRoom.key, "creator" : creatorId]
        
        newRoom.updateChildValues(data as [AnyHashable : Any]) { (err, ref) in
            if err != nil {
                print("creating room error")
            }
            
            //clear up table and refresh so new data doesn't stack
            completionHandler()
        }
        
        let userId = Auth.auth().currentUser?.uid
        let roomUsers = ref.child("\(DatabaseReferenceKeys.userRooms.rawValue)/\(userId!)")
        let roomData = [newRoom.key : 1]
        
        roomUsers.updateChildValues(roomData) { (err, ref) in
            if (err != nil) {
                print("Error updating userRooms child value")
                return
            }
        }
        
        //create roomsCheck
        let refRoomIdCheck = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(newRoom.key!)")
        
        let roomCheckInitialData = ["numCheck" : 0, "inProgress": false] as [String : Any]
        
        refRoomIdCheck.updateChildValues(roomCheckInitialData) { (err, ref) in
            if (err != nil) {
                print("Error initialising roomCheck")
                return
            }
        }
        
        //create child userState - a list of users
        let refUsersCheck = refRoomIdCheck.child("userState")
        let usersInRoom = [userId : false] as! [String : Any]
        refUsersCheck.updateChildValues(usersInRoom) { (err, ref) in
            if (err != nil) {
                print("Error initialising users in room")
                return
            }
        }
    }
    
    static func getRoomsFrom(ref: DatabaseReference, userId: String, completionHandler: @escaping ([Room]) -> Void) -> Void {
        let userRooms = ref.child(DatabaseReferenceKeys.userRooms.rawValue)
        let myRooms = userRooms.child(userId)
        var userRoomsDictionary: [Room] = []
        
        myRooms.observeSingleEvent(of: .value) { (snapshot) in
            if let object = snapshot.children.allObjects as? [DataSnapshot] {
                for obj in object {
                    awaitRoom.enter()
                    let roomId = obj.key
                    let roomRef = ref.child("\(DatabaseReferenceKeys.rooms.rawValue)/\(roomId)")
                    
                    roomRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                        let room = Room(dictionary: dictionary)
                        
                        userRoomsDictionary.append(room)
                        awaitRoom.leave()
                    })
                }
            }
            awaitRoom.notify(queue: .main, execute: {
                print(userRoomsDictionary)
                completionHandler(userRoomsDictionary)
            })
        }
    }
    
    static func readyStateUpdate(ref: DatabaseReference, userId: String, roomId: String) -> Void {
        let refRoomCheck = ref.child(DatabaseReferenceKeys.roomsCheck.rawValue)
        let refRoomIdCheck = refRoomCheck.child(roomId)
        let refUsersCheck = refRoomIdCheck.child("userState")
        
        let dataToUpdate = [userId : true]
        refUsersCheck.updateChildValues(dataToUpdate) { (err, ref) in
            if (err != nil) {
                print("Error updating ready state")
                return
            }
        }
    }
}
