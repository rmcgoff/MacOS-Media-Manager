//
//  DropView.swift
//  Assignment2
//
//  Created by Ryan McGoff on 9/19/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa
import Foundation
import AppKit

class DropView: NSView{
    

    let extensionsArray = ["png","jpg","pdf","m4a", "txt","mov"]
    
  
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.wantsLayer = true
        //sets drop view to a clear color so collectionview is still visable
        self.layer?.backgroundColor = NSColor.clear.cgColor
    
        registerForDraggedTypes([NSPasteboard.PasteboardType.URL, NSPasteboard.PasteboardType.fileURL])
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    

    
    /// When the dragged file has been dragged to the custom dropview, it checks the extension and changes the color is the draggged file's extension is one of the
    /// expected types. Otherwise it restarts the dragging session
    /// - Parameters:
    /// - sender: is a NSDraggingInfo object containing info about the dragged session
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkFileExtension(sender) == true {
            self.layer?.backgroundColor = NSColor.gray.cgColor
            
            return .copy
        } else {
            return NSDragOperation()
        }
    }
    
    /// Checks the dragged file's extension against an expected array of extensions
    /// - Parameters:
    /// - sender: is a NSDraggingInfo object containing info about the dragged session
    /// - Returns:
    /// boolean value indicating if the extension matches an expected extension
    fileprivate func checkFileExtension(_ drag: NSDraggingInfo) -> Bool {
        //gets the file path URL
        guard let board = drag.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            let path = board[0] as? String
            else { return false }
        //extracts the extension for the file path URL
        let fileExtension = URL(fileURLWithPath: path).pathExtension
        for exten in self.extensionsArray {
            if exten.lowercased() == fileExtension {
                return true
            }
        }
        return false
    }
    
    /// This method is called when the dragging session has exited, it changes the DropView's background back to a transparent color
    /// - Parameters:
    /// - sender: is a NSDraggingInfo object containing info about the dragged session
    override func draggingExited(_ sender: NSDraggingInfo?) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    /// This method is called when the dragging session has ended, it changes the DropView's background back to a transparent color
    /// - Parameters:
    /// - sender: is a NSDraggingInfo object containing info about the dragged session
    override func draggingEnded(_ sender: NSDraggingInfo) {
        self.layer?.backgroundColor = NSColor.clear.cgColor
    }
    
    /// This method retrieves the path name from the draggng pasteboard of the NSDraggingInfo object, and sends this file path as a notification to the view controller to add to the collection
    /// - Parameters:
    /// - sender: is a NSDraggingInfo option contating information about the current drag session, this is used to get the file path of the dragged item
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let droppedFile = sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "NSFilenamesPboardType")) as? NSArray,
            
            let pathURLpathURL = droppedFile[0] as? String
          
            else { return false }
        
        NotificationCenter.default.post(name: .dropItem, object: nil, userInfo: ["filePath": pathURLpathURL])
        
        return true
    }
}

