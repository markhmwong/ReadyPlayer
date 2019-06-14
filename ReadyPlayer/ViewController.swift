//
//  ViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 13/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    lazy var roomTableView: UITableView = {
       let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension
