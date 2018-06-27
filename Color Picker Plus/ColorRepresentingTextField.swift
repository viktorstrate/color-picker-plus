//
//  ColorRepresentingTextField.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 27/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ColorRepresentingTextField: NSTextField, NSTextFieldDelegate {
    
    var isHexField: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        Logger.debug(message: "Text field changed")
        
        if isHexField  {
            if self.stringValue.count != 6 {
                Logger.debug(message: "Hex field is not 6 characters long, skipping color update")
                return
            }
            
            if RGB.fromHEX(NSString(string: self.stringValue)) == nil {
                Logger.debug(message: "Hex field does not contain a valid hex value, skipping color update")
                return
            }
        }
        
        ColorPickerPlus.shared.colorFieldChanged(self)
    }

}
