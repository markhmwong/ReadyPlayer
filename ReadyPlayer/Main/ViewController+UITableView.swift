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
        let cell = tableView.dequeueReusableCell(withIdentifier: "roomCellId", for: indexPath)
        cell.textLabel?.text = viewModel?.dataSource[indexPath.row].name
        cell.textLabel?.attributedText = NSAttributedString(string: (viewModel?.dataSource[indexPath.row].name?.uppercased())!, attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = Theme.Cell.background

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height / 5.0
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let dataSource = viewModel?.dataSource else { return }
        let roomObj = dataSource[indexPath.row]
        let readyRoomViewModel = ReadyRoomViewModel(delegate: nil, room: roomObj)
        let viewController = ReadyRoomViewController(viewModel: readyRoomViewModel)
        readyRoomViewModel.delegate = viewController

        self.navigationController?.present(viewController, animated: true, completion: {
            
        })
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
