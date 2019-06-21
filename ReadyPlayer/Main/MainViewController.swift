//
//  ViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 13/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {

    var viewModel: MainViewModel?
    
    lazy var roomTableView: UITableView = {
       let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
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
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.addSubview(roomTableView)
        roomTableView.register(UITableViewCell.self, forCellReuseIdentifier: "roomIdCell")
        roomTableView.anchorView(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        
        isUserLoggedIn()
        authenticateAnonymously()
    }
    
    //move to user
    func authenticateAnonymously() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            let user = authResult?.user
            _ = user?.isAnonymous  // true
            let uid = user?.uid
            
            let ref = self.viewModel!.ref
        
            let values = ["userid" : uid, "username" : ""]
            let userRef = ref.child(DatabaseReferenceKeys.users.rawValue)
            let userIdRef = userRef.child("\(uid!)")
            
            userIdRef.updateChildValues(values as [AnyHashable : Any], withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err!)
                    return
                }
            })
        }
    }
    
    //move to viewmodel
    func isUserLoggedIn() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
        
            if (user != nil) {
                print(user!.uid)
                self.loadRoomsFor(user: user!.uid)
            }
        }
    }
    
    func loadRoomsFor(user: String) {
        Room.getRoomsFrom(ref: viewModel!.ref, userId: user) { (roomArr) in
            //assign to tableview
            self.reloadTableWithRoom(data: roomArr)
        }
    }
    
    @objc func handleCreateRoom() {
        
        let alert = UIAlertController(title: "Great Title", message: "Please input something", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Room Name", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let ref = self.viewModel!.ref
            let currentUser = Auth.auth().currentUser
            
            Room.createRoom(ref: ref, name: textField.text!, creatorId: currentUser!.uid, completionHandler: {
                //refresh room list - look for another method to do this. Althought new rooms aren't created frequently this may be okay
                Room.getRoomsFrom(ref: self.viewModel!.ref, userId: User.getCurrentLoggedInUserKey()) { (roomArr) in
                    //assign to tableview
                    self.reloadTableWithRoom(data: roomArr)
                }
            })
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
    
    func reloadTableWithRoom(data: [Room]) {
        self.viewModel?.dataSource = []
        self.viewModel?.dataSource = data
        DispatchQueue.main.async {
            self.roomTableView.reloadData()
        }
    }
}


