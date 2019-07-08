//
//  ReadyRoomViewModel.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 16/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Firebase

class ReadyRoomViewModel {
    
    weak var delegate: ReadyRoomViewController?
    
    let cellId = "userCellId"
    
    let ref = Database.database().reference(fromURL: "https://readyplayer-76fee.firebaseio.com/")
    
    var timerLimit: Double = 8.0
    
    var timer: Timer?
    
    let room: Room?    
    
    var expires: Date?
    
    var userDataSource: [User] = []
    
    var myUserId: String = User.getCurrentLoggedInUserKey()
    
    var roomTitle: String?
    
    var roomMessage: String? {
        didSet {
            delegate?.mainView.headerView.updateMessage(message: roomMessage!)
        }
    }
    
    var inProgress: Bool? {
        didSet {
            if inProgress ?? false {
                delegate?.mainView.readyButton.isHidden = false
                delegate?.mainView.readyButton.isEnabled = true
                for user in userDataSource {
                    if (myUserId == user.userId && user.state == true) {
                        delegate?.mainView.readyButton.isEnabled = false
                        delegate?.mainView.readyButton.alpha = 0.5
                    }
                }
                

                delegate?.mainView.initiateCheckButton.alpha = 0.0
                delegate?.mainView.initiateCheckButton.isEnabled = false
                startTimer()
            } else {
                delegate?.mainView.readyButton.isHidden = true
                delegate?.mainView.readyButton.isEnabled = false
                
                delegate?.mainView.initiateCheckButton.alpha = 1.0
                delegate?.mainView.initiateCheckButton.isEnabled = true
            }
        }
    }
    
    var localBegins: Date?
    
    var timeRemaining: TimeInterval = 0.0 {
        didSet {
            if (timeRemaining <= 0.0) {
                timeRemaining = 0.0
            }
        }
    }
    
    init(room: Room) {
        self.room = room
    }
    
    func startTimer() {
        if (timer == nil) {
            timer?.invalidate()
            let timerInterval = 0.1
            timer = Timer.scheduledTimer(timeInterval: timerInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func stopTimer() {
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
            expires = nil
        }
    }
    
    @objc func update() {

        guard let time = expires?.timeIntervalSince(Date()) else {
            timeRemaining = -1
            return
        }
        
        if (time <= 0) {
            // count is complete
            var userList: [String] = []
            // Prepares list to update organise userids into an array
            for user in userDataSource {
                userList.append(user.userId ?? "") //deal with missing key?
            }
            Room.readyStateUpdate(ref: ref, userId: myUserId, roomId: room!.id!, state: false, timeLimit: 0.0, userList: userList, userState: [:])
            stopTimer()
        }
        timeRemaining = time.rounded(.down)
        updateTimeLabel()
    }
    
    func updateTimeLabel() {
        guard let delegate = delegate else { return }
        delegate.mainView.headerView.updateTimeLabel(timeStr: "\(timeRemaining)")
    }
}

extension TimeInterval {
    //returns a tuple containing the seconds minutes and hours. Basically a conversion from seconds.
    func secondsToHoursMinutesSeconds() -> (Int, Int, Int) {
        let seconds = Int(self)
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
