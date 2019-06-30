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
    
    var inProgress: Bool?
    
    static var awaitRoom = DispatchGroup()
    
    init(dictionary: [String: Any]) {
        self.id = dictionary["id"] as? String
        self.creator = dictionary["creator"] as? String
        self.inviteLink = dictionary["inviteLink"] as? String
        self.name = dictionary["name"] as? String
        self.inProgress = dictionary["inProgress"] as? Bool
    }
}

extension Room {
    
    static func createRoom(ref: DatabaseReference, name: String, creatorId: String, completionHandler: @escaping () -> Void) -> Void {
        let refRooms = ref.child(DatabaseReferenceKeys.rooms.rawValue)
        let newRoom = refRooms.childByAutoId()
        
        let data = ["id" : newRoom.key, "name" : name, "inviteLink" : newRoom.key, "creator" : creatorId, "inProgress" : false] as [String : Any]
        
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
        let timeInterval = Date().timeIntervalSince1970

        let roomCheckInitialData = ["numCheck" : 0, "inProgress": false, "checkBeganDate": timeInterval as Double] as [String : Any]
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
        let userRoomsRef = ref.child(DatabaseReferenceKeys.userRooms.rawValue)
        let myRoomsRef = userRoomsRef.child(userId)
        var userRoomsDictionary: [Room] = []
        
        myRoomsRef.observeSingleEvent(of: .value) { (snapshot) in
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
                completionHandler(userRoomsDictionary)
            })
        }
    }
    
    static func playerReadyUpdate(ref: DatabaseReference, userId: String, roomId: String, state: Bool) -> Void {
        let userStateRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/userState")
        
        userStateRef.updateChildValues([userId : state]) { (err, ref) in
            if (err != nil) {
                print("Error updating player ready state")
                return
            }
        }
    }
    
    // Updates the roomsCheck node
    static func readyStateUpdate(ref: DatabaseReference, userId: String, roomId: String, state: Bool, timeLimit: Double) -> Void {
        let roomCheckRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)")
        var data: [String: Any] = [:]
        
        if (state == true) {
            data = ["inProgress" : state, "checkBeganDate" : Date().timeIntervalSince1970, "expires" :  Date().addingTimeInterval(timeLimit).timeIntervalSince1970] as [String : Any]
        } else {
            data = ["inProgress" : state, "checkBeganDate" : -1.0, "expires" : -1.0] as [String : Any]
        }
        
        roomCheckRef.updateChildValues(data) { (err, ref) in
            if (err != nil) {
                print("Error updating ready state")
                return
            }
        }
    }
    
    static func observeReadyState(ref: DatabaseReference, roomId: String, completionHandler: @escaping ([String : Bool]) -> Void) -> Void {
        let roomCheckRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/userState")
        roomCheckRef.observe(.value) { (snapshot) in
            let userStateDict = snapshot.value as? [String : Bool]
            completionHandler(userStateDict ?? [:])
        }
    }
    
    static func observeReadyStateInProgress(ref: DatabaseReference, roomId: String, completionHandler: @escaping (Bool) -> Void) -> Void {
        let roomCheckRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/inProgress")
        roomCheckRef.observe(.value) { (snapshot) in
            let inProgress = snapshot.value as? Bool
            completionHandler(inProgress!)
        }
    }

    static func observeReadyStateDate(ref: DatabaseReference, roomId: String, completionHandler: @escaping (Date) -> Void) -> Void {
        let roomCheckRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/expires")
        roomCheckRef.observe(.value) { (snapshot) in
            let date = snapshot.value as? TimeInterval
            completionHandler(Date(timeIntervalSince1970: date ?? 0))
        }
    }
    
    
    static func observeReadyStateByUser(ref: DatabaseReference, userId: String, completionHandler: @escaping ([String : Bool]) -> Void) {
        let userRoomsRef = ref.child("\(DatabaseReferenceKeys.userRooms.rawValue)/\(userId)")
        userRoomsRef.observe(.value) { (snapShot) in
            let inProgress = snapShot.value as! [String : Bool]
            completionHandler(inProgress)
        }
    }
    
    static func addNewUser(ref: DatabaseReference, userId: String, roomId: String) -> Void {
        let refUserRooms = ref.child("\(DatabaseReferenceKeys.userRooms.rawValue)/\(userId)")
        let roomData = [roomId : false] // is also the status of the room
        
        // Adds new user to an existing room
        // Add room to userRooms (database) userRooms/{userId}/{roomId}
        refUserRooms.updateChildValues(roomData) { (err, ref) in
            if (err != nil) {
                print("error getting user's rooms")
                return
            }
            print("added user to room")
        }
        
        //add to user state - roomsCheck/{roomId}/userState/{userId}
        let refRoomCheck = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/userState")
        let data = [userId : false]
        refRoomCheck.updateChildValues(data) { (err, ref) in
            if (err != nil) {
                print("error appending user to room check")
                return
            }
            print("added user to room check")
        }
        
        // todo subscribe to room
        Messaging.messaging().subscribe(toTopic: "\(roomId)") { error in
            if error != nil {
                print("error subscribing to chat room - \(roomId)")
                return
            }
            print("subscribed to chat room")
            
        }
    }
    
    static func getUsersInRoom(ref: DatabaseReference, roomId: String, completionHandler: @escaping ([User]) -> Void) -> Void {
        //waiting animation
        let roomCheckRef = ref.child("\(DatabaseReferenceKeys.roomsCheck.rawValue)/\(roomId)/userState")
        roomCheckRef.observe(.value) { (snapshot) in
            let awaitUsers = DispatchGroup()
            var userArr: [User] = []
            let userState = snapshot.value as? NSDictionary
            for user in userState! {
                awaitUsers.enter()
                let userId = user.key
                let userRef = ref.child("\(DatabaseReferenceKeys.users.rawValue)/\(userId)")
                
                userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let userData = snapshot.value as? [String: AnyObject] {
                        let user = User()
                        user.setValuesForKeys(userData)
                        userArr.append(user)
                        awaitUsers.leave()
                    }
                })
            }
            awaitUsers.notify(queue: .main, execute: {
                completionHandler(userArr)
            })
            
        }
    }
}
