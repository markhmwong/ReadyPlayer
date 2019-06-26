//
//  TimeInterval+Extension.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 24/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import Foundation

extension Date {
    
    func timeDifference(now: Date) -> TimeInterval {
        let now = now.timeIntervalSince1970
        let began = self.timeIntervalSince1970
        return now - began
    }
    
}
