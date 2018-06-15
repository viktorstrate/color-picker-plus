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
    @IBOutlet weak var colorGraphicsView: ColorGraphicsView!
    @IBOutlet weak var currentColorView: CurrentColorView!
    
    @IBOutlet weak var radioHue: NSButton!
    @IBOutlet weak var radioSaturation: NSButton!
    @IBOutlet weak var radioBrightness: NSButton!
    
    
    @IBOutlet weak var txtHue: NSTextField!
    @IBOutlet weak var txtSaturation: NSTextField!
    @IBOutlet weak var txtBrightness: NSTextField!
    @IBOutlet weak var txtHex: NSTextField!
    
    @IBOutlet weak var copyPopUp: NSPopUpButton!
    
    var firstColorChange = true
    
    public func supportsMode(_ mode: NSColorPanelMode) -> Bool {
        return mode == NSColorPanelMode.HSB
    }
    
    public func currentMode() -> NSColorPanelMode {
        return NSColorPanelMode.RGB
    }
    
    public func provideNewView(_ initialRequest: Bool) -> NSView {
        if (initialRequest) {
            let pickerNibName = "ColorPickerPlus"
            guard bundle.loadNibNamed(pickerNibName, owner: self, topLevelObjects: nil) else {
                Logger.error(message: "Could not find nib named \(pickerNibName)")
                fatalError()
            }
            
            colorGraphicsView.delegate = self

        }
        
        return pickerView
    }
    
    public func setColor(_ newColor: NSColor) {
        Logger.debug(message: "setColor() called")
        let hsv = HSV(color: newColor)
        colorGraphicsView.currentColor = hsv
        colorChanged(color: hsv)
    }
    
    private let bundle = Bundle(for: ColorPickerPlus.self)
    
    public override var provideNewButtonImage: NSImage {
        let icon = bundle.image(forResource: "ToolbarIcon")!
        return icon
    }
    
    public override var minContentSize: NSSize {
        return NSSize(width: 570, height: 356)
    }
    
    public override var buttonToolTip: String {
        get {
            return "Color Picker Plus"
        }
    }
    
}

extension ColorPickerPlus: ChangeColorDelegate {
    
    func colorChanged(color: HSV) {
        
        if (firstColorChange) {
            firstColorChange = false
        } else {
            currentColorView.color = color.toNSColor()
            
            txtHex.stringValue = color.toRGB().toHEX()
            
            super.colorPanel.color = color.toNSColor()
        }
        
        
    }
    
    
}


