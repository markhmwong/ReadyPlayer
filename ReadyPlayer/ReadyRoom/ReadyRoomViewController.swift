//
//  ReadyRoomViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 16/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ReadyRoomViewController: UIViewController {
    
    lazy var readyCheckButton: UIButton = {
        let button = UIButton()
        button.setTitle("Ready", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
        return button
    }()
    
    var viewModel: ReadyRoomViewModel?
    
    var mainView: ReadyRoomView?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let room = viewModel?.room
        print(room!.name)
        
        view.addSubview(readyCheckButton)
        readyCheckButton.anchorView(top: nil, bottom: nil, leading: nil, trailing: nil, centerY: view.centerYAnchor, centerX: view.centerXAnchor, padding: .zero, size: CGSize(width: 60.0, height: 30.0))
    }
    
    @objc func handleReadyButton() {
        guard let vm = viewModel else { return }
        let room = viewModel?.room
        Room.readyStateUpdate(ref: vm.ref, userId: User.getCurrentLoggedInUserKey(), roomId: room?.id ?? "")
        
        //initiate countdown
        vm.begins = Date()
        vm.expires = vm.begins?.addingTimeInterval(vm.timerLimit)
        vm.startTimer()
    }
}

class ReadyRoomView: UIView {
    
}
