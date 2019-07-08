//
//  ReadyRoomView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 25/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

extension ReadyRoomView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = delegate?.viewModel else { return 0 }
        return viewModel.userDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: delegate?.viewModel?.cellId ?? "userCellId", for: indexPath) as! UserCell
        cell.user = delegate?.viewModel?.userDataSource[indexPath.row]
        return cell
    }
}

class ReadyRoomView: UIView {
    
    weak var delegate: ReadyRoomViewController?
    
    lazy var headerView: ReadyRoomHeaderView = {
        guard let delegate = delegate else { return ReadyRoomHeaderView(delegate: nil) }
        let view = ReadyRoomHeaderView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var initiateCheckButton: StandardButton = {
        let button = StandardButton(title: "start")
        button.addTarget(self, action: #selector(handleInitiateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var readyButton: StandardButton = {
        let button = StandardButton(title: "READY")
        button.isHidden = true
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = Theme.GeneralView.background
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.rowHeight = UIScreen.main.bounds.height / 15.0
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(delegate: ReadyRoomViewController) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        guard let viewModel = delegate?.viewModel else { return }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        addSubview(tableView)
        addSubview(initiateCheckButton)
        addSubview(readyButton)
        
        initiateCheckButton.anchorView(top: nil, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: CGSize(width: 0, height: UIScreen.main.bounds.height / 12))
        readyButton.anchorView(top: nil, bottom: bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: CGSize(width: 0, height: UIScreen.main.bounds.height / 12))

        tableView.register(UserCell.self, forCellReuseIdentifier: viewModel.cellId)
        tableView.fillSuperView()
    }
    
    @objc func handleInitiateButton() {
        guard let vm = delegate?.viewModel else { return }
        
        //initiate countdown
        vm.localBegins = Date()
        vm.expires = vm.localBegins?.addingTimeInterval(vm.timerLimit)
        vm.startTimer()
        
        readyButton.alpha = 0.5
        readyButton.isEnabled = false
        // cloud functions sends notifications to users in chat room
        let room = vm.room
        
        let list = resetUserState(initiatorUserId: vm.myUserId)
        var userList: [String] = []
        // list of user keys
        for user in vm.userDataSource {
            userList.append(user.userId ?? "") //deal with missing key?
        }
        
        Room.readyStateUpdate(ref: vm.ref, userId: User.getCurrentLoggedInUserKey(), roomId: room?.id ?? "", state: true, timeLimit: vm.timerLimit, userList: userList, userState: list)
        
    }
    
    func resetUserState(initiatorUserId: String) -> [String : Bool] {
        guard let vm = delegate?.viewModel else { return [:] }
        var userDict: [String : Bool] = [:]
        for user in vm.userDataSource {
            if (user.userId! == initiatorUserId) {
                userDict[user.userId!] = true
            } else {
                userDict[user.userId!] = false
            }
            
        }
        return userDict
    }
    
    @objc func handleReadyButton() {
        guard let viewModel = delegate?.viewModel else { return }
        let ref = viewModel.ref
        Room.playerReadyUpdate(ref: ref, userId: viewModel.myUserId, roomId: (viewModel.room?.id!)!, state: true)
    }
}
