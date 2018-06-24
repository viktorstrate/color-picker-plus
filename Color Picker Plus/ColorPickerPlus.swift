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
    @IBOutlet weak var txtAlpha: NSTextField!
    
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
        return NSColorPanel.Mode.HSB
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
    
    @IBAction func copyAction(_ sender: NSPopUpButton) {
        Logger.debug(message: "Copy action called")
        
        var string = NSString(string: copyPopUp.selectedItem!.title)
        let startIndex = string.components(separatedBy: " - ")[0].count + 3
        
        string = NSString(string: string.substring(from: startIndex))
        
        Logger.debug(message: "Copying value to clipboard: \(string)")
        
        let pasteboard = NSPasteboard.general
        
        pasteboard.clearContents()
        pasteboard.setString(string as String, forType: .string)
    }
    
    @IBAction func changeColorComponentAction(_ sender: NSButton) {
        Logger.debug(message: "Changing active color component")
        
        if (sender == radioHue) {
            radioBrightness.state = .off
            radioSaturation.state = .off
            
            colorGraphicsView.selectedHSBComponent = .hue
            
        } else if (sender == radioSaturation) {
            radioBrightness.state = .off
            radioHue.state = .off
            
            colorGraphicsView.selectedHSBComponent = .saturation
            
        } else if (sender == radioBrightness) {
            radioHue.state = .off
            radioSaturation.state = .off
            
            colorGraphicsView.selectedHSBComponent = .brightness
            
        }
    }
    
    /// Called when the user changes any of the text fields
    @IBAction func colorFieldChanged(_ sender: NSTextField) {
        Logger.debug(message: "Color textField changed \(sender.debugDescription)")
        
        // Hex text field
        if (sender == txtHex) {
            
            var hexString = NSString(string: txtHex.stringValue)
            
            if (hexString.length < 3) {
                return
            }
            
            if (hexString.character(at: 0) == NSString(string: "#").character(at: 0)) {
                hexString = NSString(string: hexString.substring(from: 1))
                txtHex.stringValue = hexString as String
            }
            
            if (hexString.length == 3) {
                let first = hexString.substring(with: NSRange(location: 0, length: 1))
                let secnd = hexString.substring(with: NSRange(location: 1, length: 1))
                let thrd = hexString.substring(with: NSRange(location: 2, length: 1))
                
                hexString = NSString(string: "\(first)\(first)\(secnd)\(secnd)\(thrd)\(thrd)")
            }
            
            guard let rgb = RGB.fromHEX(hexString) else {
                Logger.debug(message: "Provided hex input is invalid: \(hexString)")
                return
            }
            
            let hsv = rgb.toHSV()
            
            Logger.debug(message: "Converting RGB to HSV: \(rgb) -> \(hsv)")
            
            setColor(hsv: hsv)
            return
        }
        
        // Hue text field
        if (sender === txtHue) {
            
            let hue = formatColorNumber(string: txtHue.stringValue, minimum: 0, maximum: 360)
            
            if (hue != nil) {
                var newHSV = currentColor
                newHSV.h = hue!
                setColor(hsv: newHSV)
            }
        }
        
        // Saturation text field
        if (sender === txtSaturation) {
            
            let saturation = formatColorNumber(string: txtSaturation.stringValue, minimum: 0, maximum: 100)
            
            if (saturation != nil) {
                var newHSV = currentColor
                newHSV.s = saturation! / 100
                setColor(hsv: newHSV)
            }
        }
        
        // Brightness text field
        if (sender === txtBrightness) {
            
            let brightness = formatColorNumber(string: txtBrightness.stringValue, minimum: 0, maximum: 100)
            
            if (brightness != nil) {
                var newHSV = currentColor
                newHSV.v = brightness! / 100
                setColor(hsv: newHSV)
            }
        }
        
        // Alpha text field
        if (sender === txtAlpha) {
            
            let alpha = formatColorNumber(string: txtAlpha.stringValue, minimum: 0, maximum: 100)
            
            if (alpha != nil) {
                var newHSV = currentColor
                newHSV.a = alpha! / 100
                setColor(hsv: newHSV)
            }
        }
        
        // Red text field
        if (sender === txtRed) {
            let red = formatColorNumber(string: txtRed.stringValue, minimum: 0, maximum: 255)
            
            if (red != nil) {
                var newRGB = currentColor.toRGB()
                newRGB.r = red! / 255
                setColor(hsv: newRGB.toHSV())
            }
        }
        
        // Green text field
        if (sender === txtGreen) {
            let green = formatColorNumber(string: txtGreen.stringValue, minimum: 0, maximum: 255)
            
            if (green != nil) {
                var newRGB = currentColor.toRGB()
                newRGB.g = green! / 255
                setColor(hsv: newRGB.toHSV())
            }
        }
        
        // Blue text field
        if (sender === txtBlue) {
            let blue = formatColorNumber(string: txtBlue.stringValue, minimum: 0, maximum: 255)
            
            if (blue != nil) {
                var newRGB = currentColor.toRGB()
                newRGB.b = blue! / 255
                setColor(hsv: newRGB.toHSV())
            }
        }
        
    }
    
    /// Format an input from a text field string, as a number in the range specified
    fileprivate func formatColorNumber(string: String, minimum: Int?, maximum: Int?) -> CGFloat? {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        
        guard var number = formatter.number(from: string)?.intValue else {
            Logger.warn(message: "User specified a wrong input: '\(string)'")
            return nil
        }
        
        if (minimum != nil) {
            number = max(number, minimum!)
        }
        
        if (maximum != nil) {
            number = min(number, maximum!)
        }
        
        return CGFloat(number)
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
        let hsv = color
        
        txtHex.stringValue = rgb.toHEX()
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        
        txtHue.stringValue = formatter.string(from: hsv.h as NSNumber)!
        txtSaturation.stringValue = formatter.string(from: (hsv.s * 100) as NSNumber)!
        txtBrightness.stringValue = formatter.string(from: (hsv.v * 100) as NSNumber)!
        
        txtRed.stringValue = formatter.string(from: (rgb.r * 255) as NSNumber)!
        txtGreen.stringValue = formatter.string(from: (rgb.g * 255) as NSNumber)!
        txtBlue.stringValue = formatter.string(from: (rgb.b * 255) as NSNumber)!
        
        txtAlpha.stringValue = formatter.string(from: (hsv.a * 100) as NSNumber)!
        
        let floatingNumberFormatter = NumberFormatter()
        floatingNumberFormatter.numberStyle = .decimal
        floatingNumberFormatter.maximumSignificantDigits = 3
        floatingNumberFormatter.decimalSeparator = "."
        
        let floatR = floatingNumberFormatter.string(from: NSNumber(value: Float(rgb.r)))!
        let floatG = floatingNumberFormatter.string(from: NSNumber(value: Float(rgb.g)))!
        let floatB = floatingNumberFormatter.string(from: NSNumber(value: Float(rgb.b)))!
        
        copyPopUp.removeAllItems()
        let copyMenu = copyPopUp.menu!
        
        copyMenu.addItem(withTitle: "Copy", action: nil, keyEquivalent: "")
        
        copyMenu.addItem(withTitle: "HEX - #\(rgb.toHEX())", action: nil, keyEquivalent: "c")
        
        copyMenu.addItem(withTitle: "RGB - \(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue)", action: nil, keyEquivalent: "r")
        
        copyMenu.addItem(withTitle: "Float RGB - \(floatR), \(floatG), \(floatB)", action: nil, keyEquivalent: "R")
        
        copyMenu.addItem(withTitle: "HSV - \(txtHue.stringValue), \(txtSaturation.stringValue), \(txtBrightness.stringValue)", action: nil, keyEquivalent: "H")
        
        copyMenu.addItem(NSMenuItem.separator())
        
        let webRGBItem = NSMenuItem(title: "Web RGB - rgb(\(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue))", action: nil, keyEquivalent: "w")
        webRGBItem.keyEquivalentModifierMask = [.command, .option]
        
        copyMenu.addItem(webRGBItem)
        
        let webRGBaItem = NSMenuItem(title: "Web RGBa - rgba(\(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue), \(txtAlpha.stringValue))", action: nil, keyEquivalent: "w")
        webRGBaItem.keyEquivalentModifierMask = [.command, .shift]
        
        copyMenu.addItem(webRGBaItem)
        
        let webHSLItem = NSMenuItem(title: "Web HSL - hsl(\(txtHue.stringValue), \(txtSaturation.stringValue)%, \(txtBrightness.stringValue)%)", action: nil, keyEquivalent: "w")
        webHSLItem.keyEquivalentModifierMask = [.command, .option, .shift]
        
        copyMenu.addItem(webHSLItem)
        
    }
    
    
}


