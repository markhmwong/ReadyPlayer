//
//  ProfileMainView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 6/7/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ProfileMainView: UIView {
    
    weak var delegate: ProfileViewController?
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = Theme.GeneralView.background
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(delegate: ProfileViewController) {
        super.init(frame: .zero)
        self.delegate = delegate
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        guard let viewModel = delegate?.viewModel else { return }
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = Theme.GeneralView.background
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: viewModel.cellId)
        addSubview(tableView)
        tableView.fillSuperView()
    }
    
    @objc func handleCopy() {
        let userIdStr = KeychainWrapper.standard.string(forKey: "userId")
        UIPasteboard.general.string = userIdStr
    }
    
    @objc func handleShare() {
        guard let vm = delegate?.viewModel else {
            return
        }
        let text = "userId"
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: [])
        
        delegate?.present(vc, animated: true, completion: nil)
    }
}
