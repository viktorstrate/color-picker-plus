//
//  ContainerView.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 25/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ContainerView: NSView {
    
    var colorPickerPlus: ColorPickerPlus?

    override func awakeFromNib() {
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { (event: NSEvent) -> NSEvent? in
            self.keyDown(with: event)
            return event
        }
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { (event: NSEvent) -> NSEvent? in
            self.flagsChanged(with: event)
            return event
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        Logger.debug(message: "Key down event")
        
        guard let colorPickerPlus = colorPickerPlus else {
            Logger.error(message: "ContainerView could not find ColorPickerPlus")
            return
        }
        
        guard let undoManager = colorPickerPlus.undoManager else {
            Logger.error(message: "ContainerView could not find UndoManager on ColorPickerPlus")
            return
        }
        
        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
        case [.command] where event.characters == "z":
            Logger.debug(message: "CMD+Z pressed")
            colorPickerPlus.setColor(hsv: undoManager.undo())
            break
        case [.command, .shift] where event.characters == "z":
            Logger.debug(message: "CMD+SHIFT+Z pressed")
            colorPickerPlus.setColor(hsv: undoManager.redo())
        default:
            super.keyDown(with: event)
            break
        }
        
    }
    
    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
    }
    
}
