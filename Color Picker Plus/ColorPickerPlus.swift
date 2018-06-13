//
//  ColorPickerPlus.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 13/06/2018.
//

import Foundation
import AppKit


public class ColorPickerPlus: NSColorPicker, NSColorPickingCustom {
    
    @IBOutlet var pickerView: NSView!
    
    public func supportsMode(_ mode: NSColorPanelMode) -> Bool {
        return true
    }
    
    public func currentMode() -> NSColorPanelMode {
        return NSColorPanelMode.RGB
    }
    
    public func provideNewView(_ initialRequest: Bool) -> NSView {
        if (initialRequest) {
            let pickerNibName = "ColorPickerPlus"
            guard bundle.loadNibNamed(pickerNibName, owner: self, topLevelObjects: nil) else {
                NSLog("Error: Could not find nib named \(pickerNibName)")
                fatalError()
            }
        }
        
        return pickerView
    }
    
    public func setColor(_ newColor: NSColor) {
        NSLog("Changing color")
    }
    
    private let bundle = Bundle(for: ColorPickerPlus.self)
    
    public override var provideNewButtonImage: NSImage {
        let icon = bundle.image(forResource: "ToolbarIcon")!
        return icon
    }
    
    public override var minContentSize: NSSize {
        return NSSize(width: 500, height: 270)
    }
    
}
