//
//  ProfileMainView+TableView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 6/7/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

enum UserLabels: Int {
    case userName
}

extension ProfileMainView: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let viewModel = delegate?.viewModel else { return }
        // update firebase
        User.updateUserName(ref: viewModel.ref, userId: User.getCurrentLoggedInUserKey(), userName: textField.text ?? "")
        
        //update keychain
        KeychainWrapper.standard.set(textField.text ?? "", forKey: "userName")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sect = ProfileViewModel.Sections.allCases[section]
        
        switch sect {
        case .User:
            return ProfileViewModel.UserSettings.allCases.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ProfileViewModel.Sections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ProfileViewModel.Sections.allCases[section].rawValue
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let containerView = UIView()
        containerView.backgroundColor = Theme.Cell.background
        
        let sectionString = ProfileViewModel.Sections.allCases[section].rawValue.uppercased()
        
        let label = UILabel()
        label.backgroundColor = Theme.Cell.background
        label.translatesAutoresizingMaskIntoConstraints = false
        label.attributedText = NSAttributedString(string: sectionString, attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        containerView.addSubview(label)
        label.anchorView(top: nil, bottom: nil, leading: nil, trailing: nil, centerY: containerView.centerYAnchor, centerX: containerView.centerXAnchor, padding: .zero, size: .zero)
        return containerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: delegate?.viewModel?.cellId ?? "settingsCellId", for: indexPath)
        cell.backgroundColor = Theme.Cell.background
        cell.textLabel?.attributedText = NSAttributedString(string: delegate?.viewModel?.dataSource[indexPath.section][indexPath.row].uppercased() ?? "Unknown Setting", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        
        if (indexPath.section == 0) {
            if let row = ProfileViewModel.UserSettings.init(rawValue: indexPath.row) {
                switch row {
                case ProfileViewModel.UserSettings.Username:
                    let tf = UITextField(frame: .zero)
                    tf.keyboardAppearance = .dark
                    tf.translatesAutoresizingMaskIntoConstraints = false
                    tf.delegate = self
                    tf.tag = UserLabels.userName.rawValue
                    let username = KeychainWrapper.standard.string(forKey: "userName")?.uppercased()
                    
                    tf.attributedText = NSAttributedString(string: username ?? "unknown username", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
                    cell.contentView.addSubview(tf)
                    tf.anchorView(top: cell.topAnchor, bottom: cell.bottomAnchor, leading: cell.centerXAnchor, trailing: cell.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
                case ProfileViewModel.UserSettings.UserId:
                    let textView = UITextView()
                    let userIdStr = KeychainWrapper.standard.string(forKey: "userId")
                    textView.translatesAutoresizingMaskIntoConstraints = false
                    textView.backgroundColor = .clear
                    textView.isEditable = false
                    textView.isSelectable = true
                    textView.attributedText = NSAttributedString(string: userIdStr ?? "unknown userid", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
                    cell.contentView.addSubview(textView)
                    textView.anchorView(top: cell.topAnchor, bottom: cell.bottomAnchor, leading: cell.centerXAnchor, trailing: cell.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
                }
            }
        }
        
        
        return cell
    }
}
