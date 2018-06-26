//
//  ScrollingTextField.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 26/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ScrollingTextField: NSTextField {
    
    var cursor: NSCursor?
    
    var inputField: NSTextField!
    var minValue: CGFloat! = 0
    var maxValue: CGFloat! = 100
    var numberFormatter: NumberFormatter!
    var colorPickerPlus: ColorPickerPlus!
    
    /// Mouse sensitivity
    let sensitivity: CGFloat = 1
    
    var startX: CGFloat = 0
    var startValue: CGFloat = 0
    
    func setup(inputField: NSTextField, formatter: NumberFormatter, colorPickerPlus: ColorPickerPlus, min: CGFloat = 0, max: CGFloat = 100) {
        self.inputField = inputField
        self.numberFormatter = formatter
        self.colorPickerPlus = colorPickerPlus
        self.minValue = min
        self.maxValue = max
    }

    /// Change cursor on hover
    override func resetCursorRects() {
        super.resetCursorRects()
        self.addCursorRect(self.bounds, cursor: NSCursor.resizeLeftRight)
    }
    
    override func mouseDown(with event: NSEvent) {
        Logger.debug(message: "Scroll Text Field - mouse down event")
        
        startX = event.locationInWindow.x
        let startFieldValue = numberFormatter.number(from: inputField.stringValue) ?? 0
        startValue = CGFloat(exactly: startFieldValue) ?? 0
    }
    
    override func mouseDragged(with event: NSEvent) {
        let delta = event.locationInWindow.x - startX
        
        var newValue = startValue + delta * self.sensitivity
        newValue = min(newValue, maxValue)
        newValue = max(newValue, minValue)
        
        inputField.stringValue = numberFormatter.string(from: NSNumber(value: Float(newValue))) ?? "ERR"
        colorPickerPlus.colorFieldChanged(self.inputField)
    }
    
}
