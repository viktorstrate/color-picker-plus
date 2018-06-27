//
//  ColorPickerPlus.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 13/06/2018.
//

import Foundation
import AppKit

public class ColorPickerPlus: NSColorPicker, NSColorPickingCustom {
    
    static var shared: ColorPickerPlus!
    
    @IBOutlet var pickerView: ContainerView!
    @IBOutlet weak var colorGraphicsView: ColorGraphicsView!
    @IBOutlet weak var currentColorView: CurrentColorView!
    
    @IBOutlet weak var radioHue: NSButton!
    @IBOutlet weak var radioSaturation: NSButton!
    @IBOutlet weak var radioBrightness: NSButton!
    
    @IBOutlet weak var txtHue: ColorRepresentingTextField!
    @IBOutlet weak var txtSaturation: ColorRepresentingTextField!
    @IBOutlet weak var txtBrightness: ColorRepresentingTextField!
    @IBOutlet weak var txtHex: ColorRepresentingTextField!
    
    @IBOutlet weak var txtRed: ColorRepresentingTextField!
    @IBOutlet weak var txtGreen: ColorRepresentingTextField!
    @IBOutlet weak var txtBlue: ColorRepresentingTextField!
    @IBOutlet weak var txtAlpha: ColorRepresentingTextField!
    
    @IBOutlet weak var labelRed: ScrollingTextField!
    @IBOutlet weak var labelGreen: ScrollingTextField!
    @IBOutlet weak var labelBlue: ScrollingTextField!
    @IBOutlet weak var labelAlpha: ScrollingTextField!
    
    @IBOutlet weak var copyPopUp: NSPopUpButton!
    
    var firstColorChange = true
    var currentColor: HSV {
        get {
            return colorGraphicsView.currentColor
        }
    }
    
    var undoManager: ColorUndoManager?
    
    var textFieldsNumberFormatter: NumberFormatter!

    public func supportsMode(_ mode: NSColorPanel.Mode) -> Bool {
        return true
    }
    
    public func currentMode() -> NSColorPanel.Mode {
        return NSColorPanel.Mode.HSB
    }
    
    public func provideNewView(_ initialRequest: Bool) -> NSView {
        if (initialRequest) {
            
            ColorPickerPlus.shared = self
            
            let pickerNibName = "ColorPickerPlus"
            guard bundle.loadNibNamed(NSNib.Name(rawValue: pickerNibName), owner: self, topLevelObjects: nil) else {
                Logger.error(message: "Could not find nib named \(pickerNibName)")
                fatalError()
            }

            // MARK: Initial UI Setup
            radioHue.state = NSControl.StateValue.on

            colorGraphicsView.delegate = self

            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            
            self.textFieldsNumberFormatter = formatter
            
            labelRed.setup(inputField: txtRed, formatter: formatter, min: 0, max: 255)
            labelGreen.setup(inputField: txtGreen, formatter: formatter, min: 0, max: 255)
            labelBlue.setup(inputField: txtBlue, formatter: formatter, min: 0, max: 255)
            labelAlpha.setup(inputField: txtAlpha, formatter: formatter)
            
            txtHex.isHexField = true

        }
        
        Logger.debug(message: "Picker view \(pickerView)")
        
        return pickerView
    }
    
    /// Function from protocol NSColorPickingCustom
    /// Don't call this function directly, instead use setColor(hsv: HSV)
    public func setColor(_ newColor: NSColor) {
        Logger.debug(message: "Native - setColor(NSColor) called")
        let hsv = HSV(color: newColor)
        colorGraphicsView.currentColor = hsv

        if (!firstColorChange) {
            
            if self.undoManager == nil {
                self.undoManager = ColorUndoManager(colorPickerPlus: self, initialColor: hsv)
            }
            
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
        return NSSize(width: 574, height: 356)
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
    
    func colorSettled(color: HSV) {
        undoManager?.add(color: color)
    }
    
//    func updateColorFromTextFields() {
//        
//        let formatter = self.textFieldsNumberFormatter!
//        
//        // Check if HSV has changed
//        
//        let _newHue = formatter.number(from: txtHue.stringValue)
//        let _newSat = formatter.number(from: txtSaturation.stringValue)
//        let _newBright = formatter.number(from: txtBrightness.stringValue)
//        
//        guard let newHue = _newHue, let newSat = _newSat, let newBright = _newBright else {
//            Logger.warn(message: "Hue values incorrect, ignoring")
//            return
//        }
//
//    }
    
    func updateTextFields(color: HSV) {
        var rgb = color.toRGB()
        let hsv = color
        
        // Converting between RGB and HSV is not perfect, because of rounding errors.
        // This checks if the old rgb (before the color update) is the same when converted from RGB -> HSV And not only just HSV -> RGB.
        // If they are equal, the RGB colors will not be changed
        let oldRgb = RGB.fromHEX(NSString(string: txtHex.stringValue))
        
        if let oldRgb = oldRgb {
            if hsv.equals(hsv: oldRgb.toHSV()) {
                Logger.debug(message: "Old RGB is the same!\nOriginal: \(oldRgb)\nConverted: \(rgb)")
                rgb = oldRgb
            }
        }
        
        Logger.debug(message: "Colors HSV: \(hsv), RGB: \(rgb)")
        
        txtHex.stringValue = rgb.toHEX()
        
        let formatter = self.textFieldsNumberFormatter!
        
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
        
        let hexItem = NSMenuItem(title: "HEX - #\(rgb.toHEX())", action: nil, keyEquivalent: "c")
        hexItem.keyEquivalentModifierMask = [.control]
        
        copyMenu.addItem(hexItem)
        
        let rgbItem = NSMenuItem(title: "RGB - \(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue)", action: nil, keyEquivalent: "r")
        rgbItem.keyEquivalentModifierMask = [.control]
        
        copyMenu.addItem(rgbItem)

        let floatRGBItem = NSMenuItem(title: "Float RGB - \(floatR), \(floatG), \(floatB)", action: nil, keyEquivalent: "R")
        floatRGBItem.keyEquivalentModifierMask = [.control]
        
        copyMenu.addItem(floatRGBItem)

        let hsvItem = NSMenuItem(title: "HSV - \(txtHue.stringValue), \(txtSaturation.stringValue), \(txtBrightness.stringValue)", action: nil, keyEquivalent: "h")
        hsvItem.keyEquivalentModifierMask = [.control]
        
        copyMenu.addItem(hsvItem)
        
        copyMenu.addItem(NSMenuItem.separator())
        
        let webRGBItem = NSMenuItem(title: "Web RGB - rgb(\(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue))", action: nil, keyEquivalent: "w")
        webRGBItem.keyEquivalentModifierMask = [.control]
        
        copyMenu.addItem(webRGBItem)
        
        let webRGBaItem = NSMenuItem(title: "Web RGBa - rgba(\(txtRed.stringValue), \(txtGreen.stringValue), \(txtBlue.stringValue), \(txtAlpha.stringValue))", action: nil, keyEquivalent: "w")
        webRGBaItem.keyEquivalentModifierMask = [.control, .shift]
        
        copyMenu.addItem(webRGBaItem)
        
        let webHSLItem = NSMenuItem(title: "Web HSL - hsl(\(txtHue.stringValue), \(txtSaturation.stringValue)%, \(txtBrightness.stringValue)%)", action: nil, keyEquivalent: "w")
        webHSLItem.keyEquivalentModifierMask = [.control, .option]
        
        copyMenu.addItem(webHSLItem)
        
    }
    
}


