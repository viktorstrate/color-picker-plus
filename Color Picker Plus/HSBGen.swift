// This file is based on the Huekit project by louisdh
// https://github.com/louisdh/huekit

import Foundation
import CoreGraphics

public struct RGB: Hashable {
    /// In range 0...1
    public var r: CGFloat
    
    /// In range 0...1
    public var g: CGFloat
    
    /// In range 0...1
    public var b: CGFloat
}

enum HSBComponent: Int {
    case hue = 0
    case saturation = 1
    case brightness = 2
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

public struct HSV: Hashable {
    /// In degrees (range 0...360)
    public var h: CGFloat
    
    /// Percentage in range 0...1
    public var s: CGFloat
    
    /// Percentage in range 0...1
    /// Also known as "brightness" (B)
    public var v: CGFloat
}

extension HSV {
    
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

class HSBGen {
    
    static func createBGRxImageContext(w: Int, h: Int) -> CGContext? {
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // BGRA is the most efficient on the iPhone.
        var bitmapInfo = CGBitmapInfo(rawValue: CGImageByteOrderInfo.order32Little.rawValue)
        
        let noneSkipFirst = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        bitmapInfo.formUnion(noneSkipFirst)
        
        let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w * 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        return context
    }
    
    /// Generates an image where the specified barComponentIndex (0=H, 1=S, 2=V)
    /// varies across the x-axis of the 256x1 pixel image and the other components
    /// remain at the constant value specified in the hsv array.
    static func createHSVBarContentImage(hsbComponent: HSBComponent, hsv: [CGFloat]) -> CGImage? {
        
        var hsv = hsv
        
        guard let context = createBGRxImageContext(w: 256, h: 1) else {
            return nil
        }
        
        guard var ptr = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }
        
        for x in 0..<256 {
            
            hsv[hsbComponent.rawValue] = CGFloat(x) / 255.0
            
            let hsvVal = HSV(h: hsv[0] * 360.0, s: hsv[1], v: hsv[2])
            
            let rgb = hsvVal.toRGB()
            
            ptr[0] = UInt8(rgb.b * 255.0)
            ptr[1] = UInt8(rgb.g * 255.0)
            ptr[2] = UInt8(rgb.r * 255.0)
            
            ptr = ptr.advanced(by: 4)
        }
        
        let image = context.makeImage()
        
        return image
    }
    
    static private func blend(_ value: UInt, _ percentIn255: UInt) -> UInt {
        return (value) * (percentIn255) / 255
    }
    
    // Generates a 256x256 image with the specified constant hue where the
    // Saturation and value vary in the X and Y axes respectively.
    static func createSaturationBrightnessSquareContentImageWithHue(hue: CGFloat) -> CGImage? {
        
        guard let context = createBGRxImageContext(w: 256, h: 256) else {
            return nil
        }
        
        guard var dataPtr = context.data?.assumingMemoryBound(to: UInt8.self) else {
            return nil
        }
        
        let rowBytes = context.bytesPerRow
        
        let hsv = HSV(h: hue, s: 0, v: 0)
        let rgb = hsv.hueToRGB()
        
        let r = rgb.r
        let g = rgb.g
        let b = rgb.b
        
        let r_s = (UInt) ((1.0 - r) * 255)
        let g_s = (UInt) ((1.0 - g) * 255)
        let b_s = (UInt) ((1.0 - b) * 255)
        
        // This doesn't use Swift ranges because those are pretty slow in debug builds
        
        // Width
        var s: UInt = 0
        
        while true {
            
            // Every row
            
            var ptr = dataPtr
            
            let r_hs: UInt = 255 - blend(s, r_s)
            let g_hs: UInt = 255 - blend(s, g_s)
            let b_hs: UInt = 255 - blend(s, b_s)
            
            //var v: UInt = UInt(height-100)
            var v: UInt = 255
            
            while true {
                
                // Every column
                
                // Really, these should all be of the form used in blend(),
                // which does a divide by 255. However, integer divide is
                // implemented in software on ARM, so a divide by 256
                // (done as a bit shift) will be *nearly* the same value,
                // and is faster. The more-accurate versions would look like:
                //    ptr[0] = blend(v, b_hs);
                
                ptr[0] = UInt8((v * b_hs) >> 8)
                ptr[1] = UInt8((v * g_hs) >> 8)
                ptr[2] = UInt8((v * r_hs) >> 8)
                
                ptr = ptr.advanced(by: rowBytes)
                
                if v == 0 {
                    break
                }
                
                v -= 1
            }
            
            dataPtr = dataPtr.advanced(by: 4)
            
            if s == 255 {
                break
            }
            
            s += 1
        }
        
        let image = context.makeImage()
        
        return image
    }
}
