//
//  ReadyRoomViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 16/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import Firebase

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
        self.viewModel?.delegate = self
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
        let leftButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let viewModel = viewModel else { return }
        guard let roomId = viewModel.room?.id else { return }
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = Theme.GeneralView.background
        title = viewModel.room?.name!
        view.addSubview(mainView)
        mainView.fillSuperView()
        subscribeToRoom(roomId: roomId)
        observeDateOfReadyState(roomId)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        retreiveUsersForRoom()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let ref = viewModel?.ref
        ref?.removeAllObservers()
    }
    
    func retreiveUsersForRoom() {
        guard let viewModel = viewModel else { return }
        let ref = viewModel.ref
        Room.getUsersInRoom(ref: ref, roomId: (viewModel.room?.id!)!) { (userArr) in
            viewModel.userList = []
            viewModel.userList = userArr
            viewModel.userList.sort(by: { (userA, userB) -> Bool in
                return userA.userId! < userB.userId!
            })
            DispatchQueue.main.async {
                self.mainView.tableView.reloadData()
            }
            
        }
    }
    
    func subscribeToRoom(roomId: String) {
        Messaging.messaging().subscribe(toTopic: roomId) { error in
            if error != nil {
                print("error subscribing to chat room")
                return
            }
            print("subscribed to chat room")
        }
    }
    
    func observeDateOfReadyState(_ roomId: String) {
        guard let viewModel = self.viewModel else { return }
        
        Room.observeReadyState(ref: viewModel.ref, roomId: roomId) { (userStateDict) in
            for user in viewModel.userList {
                for userState in userStateDict {
                    let key = userState.key
                    let id = user.userId!
                    if (key == id) {
                        user.state = userState.value
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.mainView.tableView.reloadData()
            }
        }
        
        Room.observeReadyStateInProgress(ref: viewModel.ref, roomId: roomId) { (inProgress) in
            viewModel.inProgress = inProgress
        }
        
        Room.observeReadyStateDate(ref: viewModel.ref, roomId: roomId) { (date) in
            viewModel.expires = date

            DispatchQueue.main.async {
                self.mainView.tableView.reloadData()
            }
        }
    }
    
    @objc func handleAddUser() {
        guard let room = viewModel?.room else { return }
        let roomId = room.id!
        
        let alert = UIAlertController(title: "Add User", message: "Enter a user Id", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Add", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let ref = self.viewModel!.ref
            let currentUser = Auth.auth().currentUser
            
            Room.addNewUser(ref: ref, userId: textField.text!, roomId: roomId)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter the unique id of the user"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
    
    @objc func handleClose() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("deinit ready room")
    }
}


