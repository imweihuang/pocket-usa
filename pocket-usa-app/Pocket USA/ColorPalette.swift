//
//  ColorPalette.swift
//
//  Created by Wei Huang on 2/14/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//
// - Attribution: Hex Colors - material.io
// - Attribution: Hex to UIColor - uicolor.xyz

import Foundation
import UIKit

// Storce color references
struct ColorPalette {
    
    // DEFAULT PICKS
    static var themeColors = [teal300, teal100, teal50, UIColor.white]
    static var textColors = [dark1, dark2, dark3, dark4]
    static var buttonColors = [tealA700, tealA400, tealA200, tealA100]
    
    // LIGHT GRAY - Alpha
    static let lightGray100 = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
    static let lightGrayA8 = UIColor.lightGray.withAlphaComponent(0.8)
    static let lightGrayA5 = UIColor.lightGray.withAlphaComponent(0.5)
    
    // LIGHT BLUE
    static let lightBlue50 = UIColor(red:0.88, green:0.96, blue:1.00, alpha:1.0)
    static let lightBlue400 = UIColor(red:0.16, green:0.71, blue:0.96, alpha:1.0)
    static let lightBlue100 = UIColor(red:0.70, green:0.90, blue:0.99, alpha:1.0)
    static let lightBlue300 = UIColor(red:0.31, green:0.76, blue:0.97, alpha:1.0)
    static let lightBlue500 = UIColor(red:0.01, green:0.66, blue:0.96, alpha:1.0)
    static let lightBlue700 = UIColor(red:0.01, green:0.53, blue:0.82, alpha:1.0)
    static let lightBlue900 = UIColor(red:0.00, green:0.34, blue:0.61, alpha:1.0)
    // LIGHT BLUE Alpha
    static let lightBlue500A8 = UIColor(red:0.01, green:0.66, blue:0.96, alpha:0.8)
    
    // INDEGO
    static let indego100 = UIColor(red:0.77, green:0.79, blue:0.91, alpha:1.0)
    
    // TEAL
    static let teal50 = UIColor(red:0.88, green:0.95, blue:0.95, alpha:1.0)
    static let teal100 = UIColor(red:0.70, green:0.87, blue:0.86, alpha:1.0)
    static let teal300 = UIColor(red:0.30, green:0.71, blue:0.67, alpha:1.0)
    static let teal500 = UIColor(red:0.00, green:0.59, blue:0.53, alpha:1.0)
    static let teal700 = UIColor(red:0.00, green:0.47, blue:0.42, alpha:1.0)
    static let teal900 = UIColor(red:0.00, green:0.30, blue:0.25, alpha:1.0)
    static let tealA100 = UIColor(red:0.65, green:1.00, blue:0.92, alpha:1.0)
    static let tealA200 = UIColor(red:0.39, green:1.00, blue:0.85, alpha:1.0)
    static let tealA400 = UIColor(red:0.11, green:0.91, blue:0.71, alpha:1.0)
    static let tealA700 = UIColor(red:0.00, green:0.75, blue:0.65, alpha:1.0)
    // TEAL - Delta
    static let teal500A8 = UIColor(red:0.00, green:0.59, blue:0.53, alpha:0.8)
    
    // DEEP ORANGE
    static let deepOrange50 = UIColor(red:1.00, green:0.80, blue:0.74, alpha:1.0)
    static let deepOrange100 = UIColor(red:1.00, green:0.80, blue:0.74, alpha:1.0)
    static let deepOrange300 = UIColor(red:1.00, green:0.54, blue:0.40, alpha:1.0)
    static let deepOrange500 = UIColor(red:1.00, green:0.34, blue:0.13, alpha:1.0)
    static let deepOrange700 = UIColor(red:0.90, green:0.29, blue:0.10, alpha:1.0)
    static let deepOrange900 = UIColor(red:0.75, green:0.21, blue:0.05, alpha:1.0)
    // DEEP ORANGE - Delta
    static let deepOrange500A8 = UIColor(red:1.00, green:0.34, blue:0.13, alpha:0.8)
    
    // LIGHT
    static let light1 = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0) // Primary text
    static let light2 = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.7) // Secondary text
    static let light3 = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5) // Disabled text, int text and icons
    static let light4 = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.12) // Dividers
    static let lightActive = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0) // Active icon
    static let lightInactive = UIColor(red:1.00, green:1.00, blue:1.00, alpha:0.5) // Inactive icon
    
    // DARK
    static let dark1 = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.87) // Primary text
    static let dark2 = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.54) // Secondary text
    static let dark3 = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.38) // Disabled text, int text and icons
    static let dark4 = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.12) // Dividers
    static let darkActive = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.53) // Active icon
    static let darkInactive = UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.38) // Iactive icon
    
    // Set Day Colors
    static func setDayColors() {
        themeColors = [teal300, teal100, teal50, UIColor.white]
        textColors = [dark1, dark2, dark3, dark4]
        buttonColors = [tealA700, tealA400, tealA200, tealA100]
    }
    
    // Set Night Colors
    static func setNightColors() {
        themeColors = [teal900, teal700, teal500, teal300]
        textColors = [light1, light2, light3, light4]
        buttonColors = [tealA700, tealA400, tealA200, tealA100]
    }
    
    // Note:
    // For Light Theme: 300 > 100 > 50 > 0
    // For Dark Theme: 1000 > 900 > 850 > 800
}
