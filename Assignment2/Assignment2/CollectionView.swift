//
//  CollectionView.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 10/2/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

//Custome CollectionView class for the application
public class CollectionView: NSCollectionView {
    
    /// Overrides the super draw function as is required, but makes no custom changes (just calls super)
    /// - Parameters:
    /// - dirtyRect: the rectangle to draw.
    override public func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    /// This method overrides the inherited NSResponder mouse down method.
    /// It calls the super method, then if the click was a double click, informs the Notification Center via the .doubleClick
    /// notification.
    /// - Parameters:
    /// - event: The NSEvent for a mouse click.
    override public func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        if event.clickCount > 1 {
           NotificationCenter.default.post(name: .doubleClick, object: nil)
        }
    }
}
