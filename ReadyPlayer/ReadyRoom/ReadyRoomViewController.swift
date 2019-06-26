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
        
        guard let roomId = viewModel?.room?.id else { return }
        
        Messaging.messaging().subscribe(toTopic: roomId) { error in
            if error != nil {
                print("error subscribing to chat room")
                return
            }
            print("subscribed to chat room")
        }
        observeDateOfReadyState(roomId)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let viewModel = viewModel else { return }
        let ref = viewModel.ref
        Room.getUsersInRoom(ref: ref, roomId: (viewModel.room?.id!)!) { (userArr) in
            print("retreived all users")
            viewModel.userList = userArr
            self.mainView.users.text = userArr[0].userName
            //update tableview
        }
    }
    
    func observeDateOfReadyState(_ roomId: String) {
        Room.observeReadyStateDate(ref: viewModel!.ref, roomId: roomId) { (date, inProgress) in
            let myDate = date
            self.viewModel?.inProgress = inProgress
            self.viewModel?.expires = date
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
}


