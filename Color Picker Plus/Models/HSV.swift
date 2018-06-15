// This file is based on the Huekit project by louisdh
// Which is licensed under the MIT Licese
//
// https://github.com/louisdh/huekit

import Foundation
import AppKit

public struct HSV: Hashable {
    /// In degrees (range 0...360)
    public var h: CGFloat
    
    /// Percentage in range 0...1
    public var s: CGFloat
    
    /// Percentage in range 0...1
    /// Also known as "brightness" (B)
    public var v: CGFloat
    
    public var a: CGFloat
    
    init (h: CGFloat, s: CGFloat, v: CGFloat) {
        self.h = h
        self.s = s
        self.v = v
        self.a = 1
    }
    
    init (h: CGFloat, s: CGFloat, v: CGFloat, a: CGFloat) {
        self.init(h: h, s: s, v: v)
        self.a = 1
    }
}

extension HSV {
    
    init (color: NSColor) {
        
        var convertedColor: NSColor!
        
        if (color.colorSpace != .genericRGB) {
            Logger.debug(message: "Changing colorspace from '\(color.colorSpace)' before converting to HSV")
            convertedColor = color.usingColorSpace(NSColorSpace.genericRGB)!
        } else {
            convertedColor = color
        }
        
        self.h = convertedColor.hueComponent * 360
        self.s = convertedColor.saturationComponent
        self.v = convertedColor.brightnessComponent
        self.a = convertedColor.alphaComponent
    }
    
    func toNSColor() -> NSColor {
        return NSColor(hue: h / 360, saturation: s, brightness: v, alpha: a)
    }
    
    /// Round hue value
    func rounded() -> HSV {
        return HSV(h: h.rounded(), s: s, v: v)
    }
    
    /// These functions convert between an RGB value with components in the
    /// 0.0..1.0 range to HSV where Hue is 0 .. 360 and Saturation and
    /// Value (aka Brightness) are percentages expressed as 0.0..1.0.
    //
    /// Note that HSB (B = Brightness) and HSV (V = Value) are interchangeable
    /// names that mean the same thing. I use V here as it is unambiguous
    /// relative to the B in RGB, which is Blue.
    func toRGB() -> RGB {
        
        var rgb = self.hueToRGB()
        
        let c = v * s
        let m = v - c
        
        rgb.r = rgb.r * c + m
        rgb.g = rgb.g * c + m
        rgb.b = rgb.b * c + m
        
        return rgb
    }
    
    func hueToRGB() -> RGB {
        
        let hPrime = h / 60.0
        
        let x = 1.0 - abs(hPrime.truncatingRemainder(dividingBy: 2.0) - 1.0)
        
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        
        if hPrime < 1.0 {
            
            r = 1
            g = x
            b = 0
            
        } else if hPrime < 2.0 {
            
            r = x
            g = 1
            b = 0
            
        } else if hPrime < 3.0 {
            
            r = 0
            g = 1
            b = x
            
        } else if hPrime < 4.0 {
            
            r = 0
            g = x
            b = 1
            
        } else if hPrime < 5.0 {
            
            r = x
            g = 0
            b = 1
            
        } else {
            
            r = 1
            g = 0
            b = x
            
        }
        
        return RGB(r: r, g: g, b: b)
    }
}
