//
//  ReadyRoomHeaderView.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 29/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class ReadyRoomHeaderView: UIView {
    
    weak var delegate: ReadyRoomViewController?
//
//    lazy var readyButton: StandardButton = {
//        let button = StandardButton(title: "READY")
//        button.isHidden = true
//        button.backgroundColor = .orange
//        button.setTitleColor(.white, for: .normal)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(handleReadyButton), for: .touchUpInside)
//        return button
//    }()
    
    lazy var time: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "0", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var roomName: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var roomMessage: UILabel = {
        let label = UILabel()
        label.attributedText = NSAttributedString(string: "", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 6.0).isActive = true
        widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width).isActive = true
        
        addSubview(roomName)
        addSubview(roomMessage)
        addSubview(time)
        roomName.anchorView(top: topAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: UIEdgeInsets(top: 10.0, left: 0.0, bottom: 0.0, right: 0.0), size: .zero)
        roomMessage.anchorView(top: roomName.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0), size: .zero)
        time.anchorView(top: roomMessage.bottomAnchor, bottom: nil, leading: nil, trailing: nil, centerY: nil, centerX: centerXAnchor, padding: .zero, size: .zero)
        guard let viewModel = delegate?.viewModel else { return }
        guard let room = viewModel.room else { return }
        let roomNameStr = room.name?.uppercased()
        let roomTitleStr = room.message?.uppercased()
        
        roomMessage.attributedText = NSAttributedString(string: roomTitleStr ?? "Unknown Name", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
        roomName.attributedText = NSAttributedString(string: roomNameStr ?? "Unknown Name", attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
    }
    
    func updateTimeLabel(timeStr: String) {
        time.attributedText = NSAttributedString(string: timeStr , attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.h4).value)!])
    }
    
    func updateMessage(message: String) {
        roomMessage.attributedText = NSAttributedString(string: message , attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b2).value)!])
    }

}
