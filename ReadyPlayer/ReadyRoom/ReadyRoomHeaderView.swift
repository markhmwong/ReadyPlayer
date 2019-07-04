//
//  ReadyRoomHeaderView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 29/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ReadyRoomHeaderView: UIView {
    
    weak var delegate: ReadyRoomViewController?
    
    lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: "READY", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!]), for: .normal)
        button.isHidden = true
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var initiateCheckButton: UIButton = {
        let button = UIButton()
        button.setAttributedTitle(NSAttributedString(string: "START", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!]), for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleInitiateButton), for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
    lazy var time: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var roomName: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()    
    
    init(delegate: ReadyRoomViewController?) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = Theme.GeneralView.background
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 4.0).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        addSubview(roomName)
        addSubview(initiateCheckButton)
        addSubview(time)
        addSubview(readyButton)
        
        initiateCheckButton.anchorView(top: time.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        roomName.anchorView(top: topAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0), size: .zero)
        time.anchorView(top: roomName.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        readyButton.anchorView(top: initiateCheckButton.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        guard let viewModel = delegate?.viewModel else { return }
        guard let room = viewModel.room else { return }
        let roomNameStr = room.name?.uppercased()
        
        roomName.attributedText = NSAttributedString(string: roomNameStr ?? "Unknown Name", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
        
    }
    
    func updateTimeLabel(timeStr: String) {
        time.attributedText = NSAttributedString(string: timeStr , attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
    }
    
    @objc func handleInitiateButton() {

        guard let vm = delegate?.viewModel else { return }
        let room = vm.room
        
        //initiate countdown
        vm.localBegins = Date()
        vm.expires = vm.localBegins?.addingTimeInterval(vm.timerLimit)
        vm.startTimer()
        
        // cloud functions sends notifications to users in chat room
        Room.readyStateUpdate(ref: vm.ref, userId: User.getCurrentLoggedInUserKey(), roomId: room?.id ?? "", state: true, timeLimit: vm.timerLimit)
    }
    
    @objc func handleReadyButton() {
        guard let viewModel = delegate?.viewModel else { return }
        let ref = viewModel.ref
        Room.playerReadyUpdate(ref: ref, userId: viewModel.myUserId, roomId: (viewModel.room?.id!)!, state: true)
    }
}
