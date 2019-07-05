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
    
    var didInitiate: Bool?
    
    var myUserId: String = User.getCurrentLoggedInUserKey()
    
    var inProgress: Bool? {
        didSet {
            
            if inProgress ?? false {
                delegate?.mainView.headerView.readyButton.isHidden = false
                startTimer()
            } else {
                delegate?.mainView.headerView.readyButton.isHidden = true
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
            // count is complete, reset room
            Room.readyStateUpdate(ref: ref, userId: myUserId, roomId: room!.id!, state: false, timeLimit: 0.0)
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
