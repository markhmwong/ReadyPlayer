//
//  ViewController+UITableView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 14/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.dataSource.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomIdCell", for: indexPath)
//        cell.backgroundColor = .red
        cell.textLabel?.text = viewModel?.dataSource[indexPath.row].name
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = viewModel?.dataSource else { return }
        let roomObj = dataSource[indexPath.row]
        let readyRoomViewModel = ReadyRoomViewModel(delegate: self, room: roomObj)
        let viewController = ReadyRoomViewController(viewModel: readyRoomViewModel)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
}
