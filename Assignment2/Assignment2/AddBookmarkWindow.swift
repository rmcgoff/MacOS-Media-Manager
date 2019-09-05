//
//  AddBookmarkWindow.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 10/1/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

/// Window controller for the window that shows up when we want to add a bookmark
class AddBookmarkWindow: NSWindowController, NSTextFieldDelegate, NSWindowDelegate {

    @IBOutlet weak var outletCreate: NSButton!
    @IBOutlet weak var outletBookmarkName: NSTextField!
    @IBOutlet var outletWindow: NSWindow!
    @IBOutlet weak var outletWarning: NSTextField!
    var outletPopUp: NSPopUpButton!
    var bookmarkController: NSArrayController!
    var AddBookmarkButton: NSButton!
    var added = false
    
    /// Initaliser that sets up the references to the popup button, array controller, and add button to be used by this
    /// controller.
    /// - Parameters:
    /// - outletPopUp: The pop up button to be changed
    /// - bookmarkController: The !rrayController button to be changed
    /// - AddBookmarkButton: The button to be changed
    convenience init(outletPopUp: NSPopUpButton!, bookmarkController: NSArrayController!, AddBookmarkButton: NSButton!){
        self.init(windowNibName: NSNib.Name(rawValue: "AddBookmarkWindow"));
        self.outletPopUp = outletPopUp
        self.bookmarkController = bookmarkController
        self.AddBookmarkButton = AddBookmarkButton
    }
    
    /// This method calls the super load method then sets the appropriate delegates and variable stats/values.
    override func windowDidLoad() {
        super.windowDidLoad()
        outletCreate.isEnabled = false
        outletBookmarkName.delegate = self
        outletWindow.delegate = self
        outletWindow.title = "Add Bookmark"
    }
    
    /// This method is called when the user clicks the create bookmark Button.
    /// It adds the bookmarks to the ViewController's static array and closes the window.
    /// - Parameters:
    /// - sender: The button that was clicked.
    @IBAction func createBookmark(_ sender: NSButton) {
        ViewController.bookmarks.append(outletBookmarkName.stringValue)
        added = true
        outletWindow.close()
    }
    
    
    /// This method is called when the window is about to be closed. It sets the state of the referenced variables
    /// as required.
    /// - Parameters:
    /// - notification: The notification sent
    func windowWillClose(_ notification: Notification){
        if added{
            let newBookmark = ViewController.bookmarks.last!
            outletPopUp.addItem(withTitle: newBookmark)
            bookmarkController.add(contentsOf: [Bookmark(string: newBookmark)])
            AddBookmarkButton.isEnabled = true
        }

    }
    
    /// This method is called whenever the text fields are modified and changes the state of the the add button from
    /// enabled to disbaled based on whether or not the add is allowed. It checks that the field aren't empty and that
    /// the metadata doesn't already exist. It also updates the warning text field to alert the user why they aren't being
    /// allowed to click the button.
    /// - Parameters:
    /// - obj: The notification sent
    override func controlTextDidChange(_ obj: Notification) {
        outletWarning.stringValue = ""
        outletCreate.isEnabled = true
        if (outletBookmarkName.stringValue.isEmpty){
            outletCreate.isEnabled = false
            return
        }
        for bookmark in (ViewController.bookmarks){
            if(bookmark.caseInsensitiveCompare(outletBookmarkName.stringValue) == ComparisonResult.orderedSame) {
                outletWarning.stringValue = "That bookmark already exists, please use a new bookmark."
                outletCreate.isEnabled = false
                return
            }
        }
    }
}
