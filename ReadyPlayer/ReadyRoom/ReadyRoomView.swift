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
        return viewModel.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "userCellId", for: indexPath) as? UserCell
        
        if (cell == nil) {
            cell = UserCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "userCellId")
        }
        
        guard let viewModel = delegate?.viewModel else { return cell! }
        cell?.textLabel!.text = viewModel.userList[indexPath.row].userName
        
        if let state = viewModel.userList[indexPath.row].state {
            if (state) {
                cell?.backgroundColor = .green
            } else {
                cell?.backgroundColor = .white
            }
        }
        

        return cell!
    }
}

class ReadyRoomView: UIView {
    
    var delegate: ReadyRoomViewController?
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("close", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(handleCloseButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var headerView: ReadyRoomHeaderView = {
        guard let delegate = delegate else { return ReadyRoomHeaderView(delegate: nil) }
       let view = ReadyRoomHeaderView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var time: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var users: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var status: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var initiateCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleInitiateButton), for: .touchUpInside)
        return button
    }()
    
    lazy var roomTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var readyButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ready", for: .normal)
        button.isHidden = true
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
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
    
    // not ready button
    @objc func handleReadyButton() {
        guard let viewModel = delegate?.viewModel else { return }
        let ref = viewModel.ref
        Room.playerReadyUpdate(ref: ref, userId: viewModel.myUserId, roomId: (viewModel.room?.id!)!, state: true)
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
    
    func setupView() {
        let room = delegate?.viewModel?.room
        roomTitle.text = "\(room?.name ?? "unknown")"
        roomTitle.sizeToFit()
        
        status.text = "status"
        status.sizeToFit()
        
        guard let delegate = delegate else { return }
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
//        addSubview(readyButton)
//        addSubview(users)
//        addSubview(status)
//        addSubview(time)
//        addSubview(roomTitle)
//        addSubview(initiateCheckButton)
        
        addSubview(tableView)
        addSubview(closeButton)

        
        tableView.register(UserCell.self, forCellReuseIdentifier: "userCellId")
        tableView.fillSuperView()
        closeButton.anchorView(top: safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: CGSize(width: 50.0, height: 30.0))
//        users.anchorView(top: status.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
//
//        status.anchorView(top: roomTitle.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
//        time.anchorView(top: nil, bottom: initiateCheckButton.topAnchor, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
//        roomTitle.anchorView(top: safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
//        initiateCheckButton.anchorView(top: nil, bottom: nil, leading: nil, trailing: nil, centerY: centerYAnchor, centerX: centerXAnchor, padding: .zero, size: CGSize(width: 60.0, height: 30.0))
//        readyButton.anchorView(top: users.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: CGSize(width: 60.0, height: 30.0))
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        

    }
    
    func updateTimeLabel(timeStr: String) {
        time.text = timeStr
    }
    
    @objc func handleCloseButton() {
        print("handle close button")
        delegate?.dismiss(animated: true, completion: nil)
    }
}
