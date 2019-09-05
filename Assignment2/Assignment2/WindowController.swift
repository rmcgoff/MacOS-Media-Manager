//
//  WindowController.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 9/26/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

/// This class controls the main window of our application. Adding a min size is it's main job. 
class WindowController: NSWindowController {
    
    @IBOutlet weak var outletWindow: NSWindow!
    
    /// Load function that sets min size.
    override func windowDidLoad() {
        super.windowDidLoad()
        outletWindow!.minSize = ((NSSize(width: 850, height: 650)))
        outletWindow!.title = "Media Manager"
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

}
