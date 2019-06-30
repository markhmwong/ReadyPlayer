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
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCellId", for: indexPath) as! RoomCell
        cell.room = viewModel?.dataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 7.0
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = viewModel?.dataSource else { return }
        let roomObj = dataSource[indexPath.row]
        let readyRoomViewModel = ReadyRoomViewModel(delegate: nil, room: roomObj)
        let viewController = ReadyRoomViewController(viewModel: readyRoomViewModel)
        readyRoomViewModel.delegate = viewController

        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.present(viewController, animated: true, completion: nil)
        
    }
    
}
