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
        let now = now.timeIntervalSinceReferenceDate
        let began = self.timeIntervalSinceReferenceDate
        return now - began
    }
    
}
