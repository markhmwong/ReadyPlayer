//
//  RoomCell.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 30/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class RoomCell: UITableViewCell {
    
    var room: Room? {
        didSet {
            //setup cell
            roomName.attributedText = NSAttributedString(string: "\(room?.name ?? "My Interesting Room Name")", attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])
            
            updateRoomStatus(status: room?.inProgress)
        }
    }
    
    lazy var roomName: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Room Name", attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var roomStatus: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "Room Status", attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = Theme.Cell.background
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCell() {
        contentView.addSubview(roomName)
        contentView.addSubview(roomStatus)
        
        roomName.anchorView(top: nil, bottom: nil, leading: nil, trailing: nil, centerY: centerYAnchor, centerX: centerXAnchor, padding: .zero, size: .zero)
        roomStatus.anchorView(top: roomName.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
    }
    
    func updateRoomStatus(status: Bool?) {
        
        var statusStr = ""
        
        guard let status = status else {
            statusStr = "Unknown"
            roomStatus.attributedText = NSAttributedString(string: statusStr, attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])
            return
        }
        
        if (status) {
            statusStr = "In Progress"
        } else {
            statusStr = "Idle"
        }
        
        roomStatus.attributedText = NSAttributedString(string: statusStr, attributes: [NSAttributedString.Key.kern : 2.0, NSAttributedString.Key.foregroundColor : UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)])

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        roomName.removeFromSuperview()
        roomStatus.removeFromSuperview()
    }
}
