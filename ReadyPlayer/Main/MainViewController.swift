//
//  ViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 13/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class MainViewController: UIViewController, UITextFieldDelegate {

    var viewModel: MainViewModel?
    
    var awaitToken = DispatchGroup()
    
    lazy var roomTableView: UITableView = {
       let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.rowHeight = UIScreen.main.bounds.height / RoomCellSize.Size.rawValue //same as delegate's method row size
        view.backgroundColor = Theme.GeneralView.background.darker(by: 2.0)
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        return view
    }()
    
    init(viewModel: MainViewModel) {
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
        let rightButton = UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(handleCreateRoom))
        let leftButton = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(handleProfile))
        self.navigationItem.rightBarButtonItem = rightButton
        self.navigationItem.leftBarButtonItem = leftButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: .zero)
        titleLabel.attributedText = NSAttributedString(string: "HOME", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        navigationItem.titleView = titleLabel
        
        // Do any additional setup after loading the view.
        view.addSubview(roomTableView)
        roomTableView.register(RoomCell.self, forCellReuseIdentifier: "roomCellId")
        roomTableView.anchorView(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        isUserLoggedIn()
        authenticateAnonymously()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let ref = viewModel?.ref
        ref?.removeAllObservers()
    }
    
    func authenticateAnonymously() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            let user = authResult?.user
            _ = user?.isAnonymous  // true
            let uid = user?.uid
            
            let ref = self.viewModel!.ref
            var deviceToken: String = ""
            self.awaitToken.enter()
            InstanceID.instanceID().instanceID { (result, error) in
                if let error = error {
                    print("Error fetching remote instance ID: \(error)")
                } else if let result = result {
                    print("Remote instance ID token: \(result.token)")

                    deviceToken = result.token
                }
                self.awaitToken.leave()
            }
            
            self.awaitToken.notify(queue: .main, execute: {
                
                let userIdRef = ref.child("\(DatabaseReferenceKeys.users.rawValue)/\(uid!)")
                let nameRef = ref.child("\(DatabaseReferenceKeys.users.rawValue)/\(uid!)/userName")
                
                userIdRef.observeSingleEvent(of: .value, with: { (snapShot) in
                    // initialises the profile
                    if (!snapShot.exists()) {
                        
                        let initialProfileData = [
                            "userId" : uid,
                            "userName" : "Guest",
                            "token" : deviceToken,
                            "created" : Date().timeIntervalSinceReferenceDate
                            ] as [String : Any]
                        
                        userIdRef.updateChildValues(initialProfileData as [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                            if err != nil {
                                print(err!)
                                return
                            }
                        })
                    } else {
                        let dict = snapShot.value as! [String : Any]
                        let userNameStr = dict["userName"] as! String
                        let userIdStr = dict["userId"] as! String
                        let tokenStr = dict["token"] as! String
                        KeychainWrapper.standard.set(userNameStr, forKey: "userName")
                        KeychainWrapper.standard.set(userIdStr, forKey: "userId")
                        KeychainWrapper.standard.set(tokenStr, forKey: "token")
                    }
                })
                
            })
        }
    }
    
    //move to viewmodel
    func isUserLoggedIn() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if (user != nil) {
                self.loadRoomsFor(user: user!.uid)
            }
        }
    }
    
    func loadRoomsFor(user: String) {
        Room.getRoomsFrom(ref: viewModel!.ref, userId: user) { (roomArr) in
            //assign to tableview
            self.observeRoomStatus(user: user)
            self.reloadTableWithRoom(data: roomArr)
        }
    }
    
    func observeRoomStatus(user: String) {
        Room.observeReadyStateByUser(ref: viewModel!.ref, userId: user) { (roomStateList) in
            guard let viewModel = self.viewModel else { return }
            
            for room in viewModel.roomDataSource {
                for state in roomStateList {
                    if (room.id == state.key) {
                        room.inProgress = state.value
                    }
                }
            }
            
            for row in self.roomTableView.visibleCells as! [RoomCell] {
                row.updateRoomStatus(status: row.room?.inProgress)
            }
        }
    }
    
    enum RoomCreationLabels: Int {
        case RoomTitle
        case RoomMessage
    }
    
    var createAction: UIAlertAction?
    
    @objc func handleCreateRoom() {
        
        //create new pop up fields in viewcontroller
        
        let alert = UIAlertController(title: "Create Room", message: "Enter your gathering", preferredStyle: UIAlertController.Style.alert)
        
        createAction = UIAlertAction(title: "Create", style: .default) { (alertAction) in
            let roomTitleTextField = alert.textFields![RoomCreationLabels.RoomTitle.rawValue]
            let roomMessageTextField = alert.textFields![RoomCreationLabels.RoomMessage.rawValue]
            
            if (roomMessageTextField.text!.isEmpty) {
                roomMessageTextField.text = "Ready Room"
            }
            
            
            let ref = self.viewModel!.ref
            let currentUser = Auth.auth().currentUser
            
            Room.createRoom(ref: ref, name: roomTitleTextField.text!, message: roomMessageTextField.text!, creatorId: currentUser!.uid, completionHandler: {
                //refresh room list - look for another method to do this. Althought new rooms aren't created frequently this may be okay
                Room.getRoomsFrom(ref: self.viewModel!.ref, userId: currentUser!.uid) { (roomArr) in
                    //assign to tableview
                    self.reloadTableWithRoom(data: roomArr)
                }
            })
        }
        createAction?.isEnabled = false
        
        alert.addTextField { (textField) in
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.textFieldIsEditing), for: .editingChanged)
            textField.tag = RoomCreationLabels.RoomTitle.rawValue
            textField.placeholder = "A Room needs a name"
        }
        
        alert.addTextField { (textField) in
            textField.tag = RoomCreationLabels.RoomMessage.rawValue
            textField.placeholder = "Describe the occasion.. (optional)"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(cancelAction)
        alert.addAction(createAction!)
        self.present(alert, animated:true, completion: nil)
    }
    
    @objc func handleProfile() {
        let vc = ProfileViewController(delegate: self, viewModel: ProfileViewModel())
        let navVc = UINavigationController(rootViewController: vc)
        navVc.navigationBar.barTintColor = Theme.Navigation.background
        self.navigationController?.present(navVc, animated: true, completion: nil)
    }
    
    func reloadTableWithRoom(data: [Room]) {
        self.viewModel?.roomDataSource = []
        self.viewModel?.roomDataSource = data
        DispatchQueue.main.async {
            self.roomTableView.reloadData()
        }
    }
    
    @objc func textFieldIsEditing(_ textField: UITextField) {
        
        if let tf = RoomCreationLabels.init(rawValue: textField.tag) {
            
            switch tf {
            case .RoomTitle:
                if (textField.text!.count <= 3) {
                    createAction?.isEnabled = false
                } else {
                    createAction?.isEnabled = true
                }
            case .RoomMessage:
                ()//optional message
            }
            
        }
        
    }
}
