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
        return viewModel?.roomDataSource.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCellId", for: indexPath) as! RoomCell
        cell.room = viewModel?.roomDataSource[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / RoomCellSize.Size.rawValue
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = viewModel?.roomDataSource else { return }
        let roomObj = dataSource[indexPath.row]
        let readyRoomViewModel = ReadyRoomViewModel(room: roomObj)
        let viewController = ReadyRoomViewController(viewModel: readyRoomViewModel)
        let navVc = UINavigationController(rootViewController: viewController)
        navVc.navigationBar.barTintColor = Theme.Navigation.background
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.present(navVc, animated: true, completion: nil)
    }
    
}
