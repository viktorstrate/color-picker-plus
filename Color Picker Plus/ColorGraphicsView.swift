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
        // Prepare variables here
    }
    
    var delegate: ChangeColorDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = NSGraphicsContext.current()!.cgContext
        
        drawMainView(context)
        drawAlphaSlider(context)
        drawSecondarySlider(context)
        
    }
    
    fileprivate struct Constants {
        static let bottomSliderHeight: CGFloat = 16.0
        static let verticalMargin: CGFloat = 8.0
    }
    
    override func mouseDown(with event: NSEvent) {
        delegate?.colorChanged(color: NSColor.red)
    }
    
    override func mouseDragged(with event: NSEvent) {
        NSLog("ColorPickerPlus: Mouse Dragged: \(event.absoluteX), \(event.absoluteY)")
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
    
    func drawMainView(_ context: CGContext) {
        
        if (hsbSquare == nil) {
            hsbSquare = HSBGen.createSaturationBrightnessSquareContentImageWithHue(hue: 0.0)
        }
        
        context.draw(hsbSquare!, in: mainViewRect())
    }
    
    func drawSecondarySlider(_ context: CGContext) {
        let bar = HSBGen.createHSVBarContentImage(hsbComponent: HSBComponent.hue, hsv: [1, 1, 1])!
        context.draw(bar, in: secondarySliderRect())
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
}

protocol ChangeColorDelegate {
    func colorChanged(color: NSColor);
}
