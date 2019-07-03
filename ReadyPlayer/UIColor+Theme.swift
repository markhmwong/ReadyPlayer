//
//  UIColor+Theme.swift
//  ReadyPlayer
//
//  Created by Mark Wong on 29/6/19.
//  Copyright © 2019 Mark Wong. All rights reserved.
//

import UIKit

struct Theme {
    
    struct Font {
        static var Name: String = "AvenirNext-Bold"
        static var Color: UIColor = .white
        enum StandardSizes: CGFloat {
            //title sizes
            case h0 = 59.0
            case h1 = 40.0
            case h2 = 30.0
            case h3 = 28.0
            case h4 = 22.0
            //body sizes
            case b0 = 20.0
            case b1 = 16.0
            case b2 = 14.0
            case b3 = 12.0
        }
        
        enum FontSize {
            case Standard(StandardSizes)
            case Custom(CGFloat)
            
            var value: CGFloat {
                switch self {
                case .Standard(let size):
                    switch UIDevice.current.screenType.rawValue {
                    case UIDevice.ScreenType.iPhones_5_5s_5c_SE.rawValue:
                        return size.rawValue * 0.8
                    case UIDevice.ScreenType.iPhoneXSMax.rawValue, UIDevice.ScreenType.iPhoneXR.rawValue:
                        return size.rawValue * 1.2
                    case UIDevice.ScreenType.iPad97.rawValue:
                        return size.rawValue * 1.2
                    case UIDevice.ScreenType.iPadPro129.rawValue, UIDevice.ScreenType.iPadPro105.rawValue, UIDevice.ScreenType.iPadPro11.rawValue:
                        return size.rawValue * 1.4
                    default:
                        return size.rawValue
                    }
                case .Custom(let customSize):
                    return customSize
                }
            }
        }
    }
    
    struct Navigation {
        static var background: UIColor = UIColor(red:0.11, green:0.11, blue:0.11, alpha:1.0)
        static var text: UIColor = UIColor.white
    }
    
    struct Cell {
        static var background: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
        static var text: UIColor = UIColor(red:0.91, green:0.53, blue:0.04, alpha:1.0)
        
        static var idle: UIColor = .green
        static var inProgress: UIColor = .yellow
    }
    
    struct GeneralView {
        static var background: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0).darker(by: 2.0)!
    }
}
