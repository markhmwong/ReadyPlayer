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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(title: "Add User", style: .plain, target: self, action: #selector(handleAddUser))
        self.navigationItem.rightBarButtonItem = rightButton
        let leftButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = leftButton
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.attributedText = NSAttributedString(string: "SETTINGS", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        navigationItem.titleView = titleLabel
        view.backgroundColor = Theme.GeneralView.background
        view.addSubview(mainView)
        mainView.fillSuperView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let roomId = viewModel?.room?.id else { return }

        retreiveUsersForRoom()
        subscribeToRoom(roomId: roomId)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let ref = viewModel?.ref
        ref?.removeAllObservers()
    }
    
    /// Grab users in room then apply an observer for their ready state
    func retreiveUsersForRoom() {
        guard let viewModel = viewModel else { return }
        guard let roomId = viewModel.room?.id else { return }
        let ref = viewModel.ref
        
        // unowned self
        Room.getUsersInRoom(ref: ref, roomId: roomId) { (userArr) in
            viewModel.userDataSource = []
            viewModel.userDataSource = userArr
            viewModel.userDataSource.sort(by: { (userA, userB) -> Bool in
                return userA.userId! < userB.userId!
            })
            DispatchQueue.main.async {
                self.mainView.tableView.reloadData()
            }
            
            self.observeDateOfReadyState(roomId)

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
        
        // unowned self
        Room.observeReadyState(ref: viewModel.ref, roomId: roomId) { (userStateDict) in
            // users are empty
            
            // match users to their state
            for user in viewModel.userDataSource {
                for userState in userStateDict {
                    let key = userState.key
                    let id = user.userId!
                    if (key == id) {
                        user.state = userState.value
                    }
                }
            }
            
//            let visibleCells = self.mainView.tableView.visibleCells as! [UserCell]
//
//            for cell in visibleCells {
//                cell.updateStatusLabel(statusStr: <#T##String#>)
//            }
            DispatchQueue.main.async {
                self.mainView.tableView.reloadData()
            }
        }
        
        Room.observeReadyStateInProgress(ref: viewModel.ref, roomId: roomId) { (inProgress) in
            viewModel.inProgress = inProgress
        }

        Room.observeReadyStateDate(ref: viewModel.ref, roomId: roomId) { (date) in
            viewModel.expires = date
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


