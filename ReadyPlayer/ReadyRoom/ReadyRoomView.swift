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
        let nameStr = viewModel.userList[indexPath.row].userName
        cell?.textLabel?.attributedText = NSAttributedString(string: nameStr?.uppercased() ?? "Unknown Name", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
        
        let userState = UILabel()
        userState.backgroundColor = .red
        userState.attributedText = NSAttributedString(string: "STATUS", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
        userState.translatesAutoresizingMaskIntoConstraints = false
        userState.textAlignment = .center
        cell?.contentView.addSubview(userState)
        userState.anchorView(top: cell?.topAnchor, bottom: cell?.bottomAnchor, leading: cell?.centerXAnchor, trailing: cell?.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        
        if let state = viewModel.userList[indexPath.row].state {
            if (state) {
                cell?.backgroundColor = .green
            } else {
                cell?.backgroundColor = Theme.Cell.background
            }
        }
        

        return cell!
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
        button.setTitle("START", for: .normal)
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
        button.setTitle("READY", for: .normal)
        button.isHidden = true
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = Theme.GeneralView.background
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
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
        guard let delegate = delegate else { return }

        let room = delegate.viewModel?.room
        roomTitle.text = "\(room?.name ?? "unknown")"
        roomTitle.sizeToFit()
        
        status.text = "status"
        status.sizeToFit()
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        addSubview(tableView)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: "userCellId")
        tableView.fillSuperView()
    }
}
