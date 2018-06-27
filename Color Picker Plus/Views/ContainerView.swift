//
//  ContainerView.swift
//  Color Picker Plus
//
//  Created by Viktor Hundahl Strate on 25/06/2018.
//  Copyright © 2018 Viktor Hundahl Strate. All rights reserved.
//

import Cocoa

class ContainerView: NSView {
    
    var colorPickerPlus: ColorPickerPlus {
        get {
            return ColorPickerPlus.shared
        }
    }

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

        Logger.debug(message: "Check for undo/redo shortcut")
        
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
            break
        }
        
    }
    
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        
        guard let undoManager = colorPickerPlus.undoManager else {
            return false
        }
        
        if event.characters == "z" {
            if event.modifierFlags == [.command]  {
                return undoManager.canUndo
            }
            
            if event.modifierFlags == [.command, .shift] {
                return undoManager.canRedo
            }
        }
        
        return false
    }
    
    override func flagsChanged(with event: NSEvent) {
        super.flagsChanged(with: event)
    }
    
}
