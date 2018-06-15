//
//  ColorGraphicsView.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 13/06/2018.
//

import Cocoa

@IBDesignable
class ColorGraphicsView: NSView {
    
    override func prepareForInterfaceBuilder() {
        currentColor = HSV(h: 40, s: 0.8, v: 0.7)
    }
    
    var delegate: ChangeColorDelegate?
    var selectedSlider: Sliders = .Main
    
    enum Sliders {
        case Main
        case Secondary
        case Alpha
    }
    
    var currentColor: HSV = HSV(h: 0, s: 1, v: 1) {
        didSet {
            needsDisplay = true
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = NSGraphicsContext.current()!.cgContext
        
        drawMainView(context)
        drawMainCircleIndicator(context)
        
        drawAlphaSlider(context)
        drawSecondarySlider(context)
        
        
    }
    
    fileprivate struct Constants {
        static let bottomSliderHeight: CGFloat = 16.0
        static let verticalMargin: CGFloat = 8.0
    }
    
    override func mouseDown(with event: NSEvent) {
        
        guard let localPoint = window?.contentView?.convert(event.locationInWindow, to: self) else {
            Logger.warn(message: "Could not convert window point to local point")
            return
        }
        
        if (mainViewRect().contains(localPoint)) {
            selectedSlider = .Main
            
        } else if (secondarySliderRect().contains(localPoint)) {
            selectedSlider = .Secondary
            
        } else if (alphaSliderRect().contains(localPoint)) {
            selectedSlider = .Alpha
        }
        
        Logger.debug(message: "Selected slider \(selectedSlider)")
    }
    
    override func mouseDragged(with event: NSEvent) {
        
        var newColor = currentColor
        
        if (selectedSlider == .Main) {
            let mainWindowRect = convert(mainViewRect(), to: window?.contentView)
            
            var x = (event.locationInWindow.x - mainWindowRect.minX) / mainWindowRect.width
            var y = (event.locationInWindow.y - mainWindowRect.minY) / mainWindowRect.height
            
            x = min(1, x)
            x = max(0, x)
            
            y = min(1, y)
            y = max(0, y)
            
            Logger.debug(message: "Saturation \(x), Brightness \(y)")

            newColor.s = x
            newColor.v = y
            
        } else if (selectedSlider == .Secondary) {
            let secondaryWindowRect = convert(secondarySliderRect(), to: window?.contentView)
            
            var x = (event.locationInWindow.x - secondaryWindowRect.minX) / secondaryWindowRect.width
            
            x = min(1, x)
            x = max(0, x)
            
            Logger.debug(message: "Hue \(x)")
            
            newColor.h = x * 360
        }
        
        currentColor = newColor
        delegate?.colorChanged(color: newColor)
        
    }
    
    // Rects
    
    func mainViewRect() -> NSRect {
        
        let bottomMargin: CGFloat = Constants.bottomSliderHeight * 2 + Constants.verticalMargin * 2
        let height = bounds.height - bottomMargin
        
        let smallestSize = min(bounds.width, height)
        let difference = max(height - bounds.width, 0.0)
        
        return NSRect(x: bounds.minX, y: bounds.minY + bottomMargin + difference, width: smallestSize, height: smallestSize)
    }
    
    func alphaSliderRect() -> NSRect {
        
        let mainRect = mainViewRect()
        
        return NSRect(x: bounds.minX, y: mainRect.minY - (Constants.verticalMargin * 2 + Constants.bottomSliderHeight * 2), width: mainRect.width, height: Constants.bottomSliderHeight)
    }
    
    func secondarySliderRect() -> NSRect {
        
        let mainRect = mainViewRect()
        
        return NSRect(x: bounds.minX, y: mainRect.minY - (Constants.verticalMargin + Constants.bottomSliderHeight), width: mainRect.width, height: Constants.bottomSliderHeight)
    }
    
    // Draw functions
    var hsbSquare: CGImage?
    var hsbSquareColor: HSV = HSV(h: 0, s: 1, v: 1)
    
    func drawMainView(_ context: CGContext) {
        
        if (hsbSquare == nil || hsbSquareColor.h != currentColor.h) {
            hsbSquareColor = currentColor
            hsbSquare = HSBGen.createSaturationBrightnessSquareContentImageWithHue(hue: currentColor.h)
        }
        
        context.draw(hsbSquare!, in: mainViewRect())
    }
    
    func drawSecondarySlider(_ context: CGContext) {
        
        let sliderRect = secondarySliderRect()
        
        let bar = HSBGen.createHSVBarContentImage(hsbComponent: HSBComponent.hue, hsv: [1, 1, 1])!
        context.draw(bar, in: sliderRect)
        
        let x = currentColor.h / 360 * sliderRect.width
        
        drawPointingArrow(context, position: CGPoint(x: x, y: sliderRect.maxY))
    }
    
    func drawAlphaSlider(_ context: CGContext) {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let color = NSColor.red.cgColor
        let colors = [color.copy(alpha: 0), color] as CFArray
        let alphaRec = alphaSliderRect()
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: nil)!
        
        context.clip(to: alphaRec)
        
        context.drawLinearGradient(gradient, start: CGPoint(x: alphaRec.minX, y: alphaRec.maxY), end: CGPoint(x: alphaRec.maxX, y: alphaRec.maxY), options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        
        context.resetClip()
    }
    
    func drawMainCircleIndicator(_ context: CGContext) {
        
        let viewRect = mainViewRect()
        
        let x = currentColor.s * viewRect.width
        let y = currentColor.v * viewRect.height
        
        context.clip(to: viewRect)
        
        NSColor.white.setStroke()
        context.addEllipse(in: CGRect(x: x - 4, y: y - 4 + viewRect.minY, width: 8, height: 8))
        context.strokePath()
        
        context.resetClip()
    }
    
    func drawPointingArrow(_ context: CGContext, position: CGPoint) {
        
        let size: CGFloat = 0.25
        
        let pos = CGPoint(x: position.x, y: position.y - 30 * size - 6)
        
        context.beginPath()
        context.move(to: CGPoint(x: pos.x - 15 * size, y: pos.y - 30 * size))
        context.addLine(to: CGPoint(x: pos.x + 15 * size, y: pos.y - 30 * size))
        
        context.addArc(center: CGPoint(x: pos.x + 15 * size, y: pos.y - 20 * size), radius: 10 * size, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: false)
        
        context.addLine(to: CGPoint(x: pos.x + 25 * size, y: pos.y))
        context.addLine(to: CGPoint(x: pos.x, y: pos.y + 30 * size))
        context.addLine(to: CGPoint(x: pos.x - 25 * size, y: pos.y))
        context.addLine(to: CGPoint(x: pos.x - 25 * size, y: pos.y - 20 * size))
        
        context.addArc(center: CGPoint(x: pos.x - 15 * size, y: pos.y - 20 * size), radius: 10 * size, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: false)
        
        context.closePath()
        
        NSColor.black.withAlphaComponent(0.1).setStroke()
        NSColor.white.setFill()
        
        context.drawPath(using: CGPathDrawingMode.fillStroke)
        
        
    }
}

protocol ChangeColorDelegate {
    func colorChanged(color: HSV);
}
