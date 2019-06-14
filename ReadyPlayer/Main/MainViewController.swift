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
        roomTableView.register(UITableViewCell.self, forCellReuseIdentifier: "roomId")
        roomTableView.anchorView(top: view.topAnchor, bottom: view.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        

        
        authenticateAnonymously()
    }
    
    func authenticateAnonymously() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            let user = authResult?.user
            let isAnonymous = user?.isAnonymous  // true
            let uid = user?.uid
            
            let ref = Database.database().reference(fromURL: "https://readyplayer-76fee.firebaseio.com/")
        
            let values = ["userid" : uid, "username" : ""]
            let userRef = ref.child("users")
            let userIdRef = userRef.child("\(uid!)")
            
            
            userIdRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print(err)
                    return
                }

                print("User has been saved")
            })
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            guard user == nil else {
                return
            }
            
            print("user \(user?.uid)")
        }
    }
    
    @objc func handleCreateRoom() {
        print("create room")
        
        let alert = UIAlertController(title: "Great Title", message: "Please input something", preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "Room Name", style: .default) { (alertAction) in
            let textField = alert.textFields![0] as UITextField
            let ref = Database.database().reference()
            Room.createRoom(databaseRef: ref, name: textField.text!)
        }
        
        alert.addTextField { (textField) in
            textField.placeholder = "Enter your name"
        }
        
        alert.addAction(action)
        self.present(alert, animated:true, completion: nil)
    }
}


