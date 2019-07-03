//
//  ReadyRoomHeaderView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 29/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ReadyRoomHeaderView: UIView {
    
    lazy var roomName: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var delegate: ReadyRoomViewController?
    
    init(delegate: ReadyRoomViewController?) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor = Theme.GeneralView.background
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 5.0).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        addSubview(roomName)
        roomName.anchorView(top: topAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: UIEdgeInsets(top: 50.0, left: 0.0, bottom: 0.0, right: 0.0), size: .zero)
        guard let viewModel = delegate?.viewModel else { return }
        guard let room = viewModel.room else { return }
        let roomNameStr = room.name?.uppercased()
        
        roomName.attributedText = NSAttributedString(string: roomNameStr ?? "Unknown Name", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)])
        
    }
}
