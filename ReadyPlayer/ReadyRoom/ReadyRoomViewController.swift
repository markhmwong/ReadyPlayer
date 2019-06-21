//
//  ReadyRoomViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 16/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ReadyRoomViewController: UIViewController {
    
    var viewModel: ReadyRoomViewModel?
    
    lazy var mainView: ReadyRoomView = {
       let view = ReadyRoomView(delegate: self)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    init(viewModel: ReadyRoomViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let rightButton = UIBarButtonItem(title: "Add User", style: .plain, target: self, action: #selector(handleAddUser))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(mainView)
        mainView.fillSuperView()
    }
    
    @objc func handleAddUser() {
        
        // get room id
        
        // 
        
    }
}

class ReadyRoomView: UIView {
    
    var delegate: ReadyRoomViewController?
    
    lazy var time: UILabel = {
       let label = UILabel()
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var readyCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ready", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    lazy var roomTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(delegate: ReadyRoomViewController) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleReadyButton() {
        guard let vm = delegate?.viewModel else { return }
        let room = vm.room
        Room.readyStateUpdate(ref: vm.ref, userId: User.getCurrentLoggedInUserKey(), roomId: room?.id ?? "")
        
        //initiate countdown
        vm.begins = Date()
        vm.expires = vm.begins?.addingTimeInterval(vm.timerLimit)
        vm.startTimer()
    }
    
    func setupView() {
        let room = delegate?.viewModel?.room
        roomTitle.text = "\(room?.name ?? "unknown")"
        roomTitle.sizeToFit()
        
        addSubview(time)
        addSubview(roomTitle)
        addSubview(readyCheckButton)
        time.anchorView(top: nil, bottom: readyCheckButton.topAnchor, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        roomTitle.anchorView(top: safeAreaLayoutGuide.topAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        readyCheckButton.anchorView(top: nil, bottom: nil, leading: nil, trailing: nil, centerY: centerYAnchor, centerX: centerXAnchor, padding: .zero, size: CGSize(width: 60.0, height: 30.0))
    }
    
    func updateTimeLabel(timeStr: String) {
        time.text = timeStr
    }
}
