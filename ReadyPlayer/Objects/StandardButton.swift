//
//  RoundedButton.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 5/7/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class StandardButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        self.setupButton(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButton(title: String) {
        translatesAutoresizingMaskIntoConstraints = false
        
        let titleStr = title.uppercased()
        setAttributedTitle(NSAttributedString(string: titleStr, attributes: [NSAttributedString.Key.foregroundColor : Theme.Font.Color, NSAttributedString.Key.font: UIFont(name: Theme.Font.Name, size: Theme.Font.FontSize.Standard(.b1).value)!]), for: .normal)
        backgroundColor = .orange
    }
    
    override var intrinsicContentSize: CGSize {
        let intrinsicContentSize = super.intrinsicContentSize
        let adjustedWidth = intrinsicContentSize.width + titleEdgeInsets.left + titleEdgeInsets.right
        let adjustedHeight = intrinsicContentSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom
        return CGSize(width: adjustedWidth, height: adjustedHeight)
    }
}
