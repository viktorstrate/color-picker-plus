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
    
    @IBOutlet weak var txtRed: NSTextField!
    @IBOutlet weak var txtGreen: NSTextField!
    @IBOutlet weak var txtBlue: NSTextField!
    
    @IBOutlet weak var copyPopUp: NSPopUpButton!
    
    var firstColorChange = true
    var currentColor: HSV {
        get {
            return colorGraphicsView.currentColor
        }
    }
    
    public func supportsMode(_ mode: NSColorPanel.Mode) -> Bool {
        return true
    }
    
    public func currentMode() -> NSColorPanel.Mode {
        return NSColorPanel.Mode.RGB
    }
    
    public func provideNewView(_ initialRequest: Bool) -> NSView {
        if (initialRequest) {
            let pickerNibName = "ColorPickerPlus"
            guard bundle.loadNibNamed(NSNib.Name(rawValue: pickerNibName), owner: self, topLevelObjects: nil) else {
                Logger.error(message: "Could not find nib named \(pickerNibName)")
                fatalError()
            }
            
            radioHue.state = NSControl.StateValue.on
            
            colorGraphicsView.delegate = self

        }
        
        return pickerView
    }
    
    /// Function from protocol NSColorPickingCustom
    /// Don't call this function directly, instead use setColor(hsv: HSV)
    public func setColor(_ newColor: NSColor) {
        Logger.debug(message: "Native - setColor(NSColor) called")
        let hsv = HSV(color: newColor)
        colorGraphicsView.currentColor = hsv
        if (!firstColorChange) {
            colorChanged(color: hsv)
        } else {
            firstColorChange = false
        }
        
    }
    
    /// Identical function to setColor(NSColor),
    /// but more accurate as it uses HSV instead of NSColor.
    public func setColor(hsv: HSV) {
        Logger.debug(message: "Improved - setColor(HSV) called")
        colorGraphicsView.currentColor = hsv
        colorChanged(color: hsv)
    }
    
    private let bundle = Bundle(for: ColorPickerPlus.self)
    
    public override var provideNewButtonImage: NSImage {
        let icon = bundle.image(forResource: NSImage.Name(rawValue: "ToolbarIcon"))!
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
    
    /// Called when the user changes any of the text fields
    @IBAction func colorFieldChanged(_ sender: NSTextField) {
        Logger.debug(message: "Color textField changed \(sender.debugDescription)")
        if (sender == txtHex) {
            
            if (NSString(string: txtHex.stringValue).character(at: 0) == NSString(string: "#").character(at: 0)) {
                txtHex.stringValue = NSString(string: txtHex.stringValue).substring(from: 1)
            }
            
            guard let rgb = RGB.fromHEX(txtHex.stringValue as NSString) else {
                Logger.debug(message: "Provided hex input is invalid: \(txtHex.stringValue)")
                return
            }
            
            let hsv = rgb.toHSV()
            
            Logger.debug(message: "Converting RGB to HSV: \(rgb) -> \(hsv)")
            
            setColor(hsv: hsv)
            return
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        
        if (sender === txtHue) {
            //var newHSV = currentColor
            // TODO: HER
            //newHSV.h = formatter.number(from: txtHue.stringValue)! as CGFloat
            //setColor(hsv: newHSV)
        }
    }
}

extension ColorPickerPlus: ChangeColorDelegate {
    
    func colorChanged(color: HSV) {
        
        currentColorView.color = color.toNSColor()
        
        updateTextFields(color: color)
        
        super.colorPanel.color = color.toNSColor()
        
    }
    
    func updateTextFields(color: HSV) {
        let rgb = color.toRGB()
        let hsv = color.rounded()
        
        txtHex.stringValue = rgb.toHEX()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        
        txtHue.stringValue = formatter.string(from: hsv.h as NSNumber)!
        txtSaturation.stringValue = formatter.string(from: (hsv.s * 100) as NSNumber)!
        txtBrightness.stringValue = formatter.string(from: (hsv.v * 100) as NSNumber)!
        
        txtRed.stringValue = formatter.string(from: (rgb.r * 255) as NSNumber)!
        txtGreen.stringValue = formatter.string(from: (rgb.g * 255) as NSNumber)!
        txtBlue.stringValue = formatter.string(from: (rgb.b * 255) as NSNumber)!
        
    }
    
    
}


