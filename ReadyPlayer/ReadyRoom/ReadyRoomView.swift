//
//  ReadyRoomView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 25/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

extension ReadyRoomView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = delegate?.viewModel else { return 0 }
        return viewModel.userDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: delegate?.viewModel?.cellId ?? "userCellId", for: indexPath) as! UserCell
        cell.user = delegate?.viewModel?.userDataSource[indexPath.row]
        return cell
    }
}

class ReadyRoomView: UIView {
    
    weak var delegate: ReadyRoomViewController?
    
    lazy var headerView: ReadyRoomHeaderView = {
        guard let delegate = delegate else { return ReadyRoomHeaderView(delegate: nil) }
        let view = ReadyRoomHeaderView(delegate: delegate)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = Theme.GeneralView.background
        view.separatorStyle = UITableViewCell.SeparatorStyle.none
        view.rowHeight = UIScreen.main.bounds.height / 8.0
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    init(delegate: ReadyRoomViewController) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        guard let viewModel = delegate?.viewModel else { return }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = headerView
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        addSubview(tableView)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: viewModel.cellId)
        tableView.fillSuperView()
    }
}
