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

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let context = NSGraphicsContext.current()!.cgContext
        
        drawMainView(context)
        drawAlphaSlider(context)
        drawSecondarySlider(context)
        
        NSLog("Bounds \(bounds.width), \(bounds.height)")
        
        
        // Drawing code here.
    }
    
    fileprivate struct Constants {
        static let bottomSliderHeight: CGFloat = 24.0
        static let verticalMargin: CGFloat = 8.0
    }
    
    // Rects
    
    func mainViewRect() -> NSRect {
        let offset: CGFloat = Constants.bottomSliderHeight * 2 + Constants.verticalMargin * 2
        return NSRect(x: bounds.minX, y: bounds.minY + offset, width: bounds.width, height: bounds.height - offset)
    }
    
    func alphaSliderRect() -> NSRect {
        return NSRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: Constants.bottomSliderHeight)
    }
    
    func secondarySliderRect() -> NSRect {
        let offset = Constants.bottomSliderHeight + Constants.verticalMargin
        return NSRect(x: bounds.minX, y: bounds.minY + offset, width: bounds.width, height: Constants.bottomSliderHeight)
    }
    
    // Draw functions
    
    func drawMainView(_ context: CGContext) {
        let square = HSBGen.createSaturationBrightnessSquareContentImageWithHue(hue: 0.0)!
        
        context.draw(square, in: mainViewRect())
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
