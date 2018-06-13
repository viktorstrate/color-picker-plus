//
//  ColorGraphicsView.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 13/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

@IBDesignable
class ColorGraphicsView: NSView {
    
    override func prepareForInterfaceBuilder() {
        // Prepare variables here
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        drawMainView()
        
        NSRectFill(secondarySliderRect())
        NSRectFill(alphaSliderRect())
        
        let square = HSBGen.createSaturationBrightnessSquareContentImageWithHue(hue: 0.0)!
        let context = NSGraphicsContext.current()!.cgContext
        
        context.draw(square, in: bounds)
        
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
    
    func drawMainView() {
        
    }
    
}
