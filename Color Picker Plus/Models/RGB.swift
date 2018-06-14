// This file is based on the Huekit project by louisdh
// Which is licensed under the MIT Licese
//
// https://github.com/louisdh/huekit

import Foundation
import AppKit

public struct RGB: Hashable {
    /// In range 0...1
    public var r: CGFloat
    
    /// In range 0...1
    public var g: CGFloat
    
    /// In range 0...1
    public var b: CGFloat
}

public extension RGB {
    init (color: NSColor) {
        r = color.redComponent
        g = color.greenComponent
        b = color.blueComponent
    }
}

public extension RGB {
    func toHEX() -> String {
        
        let hexR = convertNumber(hex: r)
        let hexG = convertNumber(hex: g)
        let hexB = convertNumber(hex: b)
        
        return hexR + hexG + hexB
    }
    
    fileprivate func convertNumber(hex number: CGFloat) -> String {
        var strNum = String(Int(number * 255), radix: 16)
        
        if (strNum.count < 2) {
            strNum = "0" + strNum
        }
        
        return strNum
        
    }
    
}

public extension RGB {
    
    func toHSV(preserveHS: Bool, h: CGFloat = 0, s: CGFloat = 0) -> HSV {
        
        var h = h
        var s = s
        var v: CGFloat = 0
        
        var max = r
        
        if max < g {
            max = g
        }
        
        if max < b {
            max = b
        }
        
        var min = r
        
        if min > g {
            min = g
        }
        
        if min > b {
            min = b
        }
        
        // Brightness (aka Value)
        v = max
        
        // Saturation
        var sat: CGFloat = 0.0
        
        if max != 0.0 {
            sat = (max - min) / max
            s = sat
        } else {
            sat = 0.0
            
            // Black, so sat is undefined, use 0
            if !preserveHS {
                s = 0.0
            }
        }
        
        // Hue
        var delta: CGFloat = 0
        
        if sat == 0.0 {
            // No color, so hue is undefined, use 0
            if !preserveHS {
                h = 0.0
            }
        } else {
            delta = max - min
            
            var hue: CGFloat = 0
            
            if r == max {
                hue = (g - b) / delta
            } else if g == max {
                hue = 2 + (b - r) / delta
            } else {
                hue = 4 + (r - g) / delta
            }
            
            hue /= 6.0
            
            if hue < 0.0 {
                hue += 1.0
            }
            
            // 0.0 and 1.0 hues are actually both the same (red)
            if !preserveHS || abs(hue - h) != 1.0 {
                h = hue
            }
        }
        
        return HSV(h: h, s: s, v: v)
    }
    
}
