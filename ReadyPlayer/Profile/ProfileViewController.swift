//
//  ProfileViewController.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 1/7/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ProfileViewModel {
    let cellId = "settingsCellId"
    
    let dataSource = [
        ["Username"],
    ]
    
    enum Sections: String, CaseIterable {
        case User = "User"
    }
    
    enum UserSettings: String, CaseIterable {
        case Username
    }
}

class ProfileMainView: UIView {

    var delegate: ProfileViewController?
    
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
    
}

extension ProfileMainView: UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
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
        
        let tf = UITextField(frame: .zero)
        tf.keyboardAppearance = .dark
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.delegate = self
        let username = KeychainWrapper.standard.string(forKey: "username")?.uppercased()
        tf.attributedText = NSAttributedString(string: username ?? "unknown username", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        cell.contentView.addSubview(tf)
        tf.anchorView(top: cell.topAnchor, bottom: cell.bottomAnchor, leading: cell.centerXAnchor, trailing: cell.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        return cell
    }
}

class ProfileViewController: UIViewController {
    
    var viewModel: ProfileViewModel?
    
    weak var delegate: MainViewController?
    
    lazy var mainView: ProfileMainView = {
        let view = ProfileMainView(delegate: self)
        return view
    }()
    
    init(delegate: MainViewController, viewModel: ProfileViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .orange
        let leftButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleClose))
        navigationItem.leftBarButtonItem = leftButton
        let titleLabel = UILabel(frame: .zero)
        titleLabel.attributedText = NSAttributedString(string: "SETTINGS", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b3).value)!])
        navigationItem.titleView = titleLabel
        view.addSubview(mainView)
        mainView.anchorView(top: view.safeAreaLayoutGuide.topAnchor, bottom: view.bottomAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    @objc func handleClose() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
}
