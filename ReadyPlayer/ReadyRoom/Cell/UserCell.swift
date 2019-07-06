//
//  ReadyRoomCell.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 28/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    var user: User? {
        didSet {
            
            let userNameStr = "\(user?.userName ?? "UnknownName")"
            
            textLabel?.attributedText = NSAttributedString(string: userNameStr.uppercased(), attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
            
            guard let state = user?.state else {
                status.attributedText = NSAttributedString(string: "NOT READY", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
                contentView.addSubview(status)
                return
            }
            var stateStr = ""
            var stateColor: UIColor = .red
            if (state) {
                stateStr = "READY"
                stateColor = .green
            } else {
                stateStr = "NOT READY"
                stateColor = .red
            }
            
            status.backgroundColor = stateColor
            status.textAlignment = .center
            status.attributedText = NSAttributedString(string: stateStr, attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
            contentView.addSubview(status)
            status.anchorView(top: topAnchor, bottom: bottomAnchor, leading: centerXAnchor, trailing: trailingAnchor, centerY: nil, centerX: nil, padding: .zero, size: .zero)
        }
    }
    
    lazy var status: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "READY", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        contentView.backgroundColor = Theme.GeneralView.background
        textLabel?.textColor = Theme.Font.Color
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        status.removeFromSuperview()
    }
}
