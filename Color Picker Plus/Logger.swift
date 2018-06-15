//
//  DLog.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 15/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Foundation

class Logger {
    
    static let tagName = "ColorPickerPlus"
    
    static func debug (message: String, function: String = #function) {
        #if DEBUG
        NSLog("\(tagName): DEBUG [\(function)] \(message)")
        #endif
    }
    
    static func warn (message: String, function: String = #function) {
        NSLog("\(tagName): WARN [\(function) \(message)]")
    }
    
    static func error (message: String, function: String = #function) {
        NSLog("\(tagName): ERROR [\(function) \(message)]")
    }
}
