//
//  ReadyRoomCell.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 28/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = Theme.GeneralView.background
        textLabel?.textColor = Theme.Font.Color

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
