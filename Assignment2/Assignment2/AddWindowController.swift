//
//  AddWindowController.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 9/30/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

/// This class controls the window that shows up when users wish to add metadata. 
class AddWindowController: NSWindowController, NSTextFieldDelegate, NSWindowDelegate {
    var file: File? = nil
    var closed = false
    @IBOutlet weak var outletNewValue: NSTextField!
    @IBOutlet weak var outletNewKey: NSTextField!
    @IBOutlet var outletWindow: NSWindow!
    @IBOutlet weak var outletAddButton: NSButton!
    @IBOutlet weak var outletWarning: NSTextField!
    var addButton: NSButton!
    var library =  Collection()
    
    /// Initaliser that sets up the references to the library and button values to be changed
    /// - Parameters:
    /// - library: The library to be used
    /// - button: The button to be used
    convenience init(library: Collection, button: NSButton! ){
        self.init(windowNibName: NSNib.Name(rawValue: "AddWindowController"));
        self.library = library
        self.addButton = button
    }
    
   /// This method calls the super load method then sets the appropriate delegates and variable stats/values.
    override func windowDidLoad() {
        super.windowDidLoad()
        outletWindow.delegate = self
        outletAddButton.isEnabled = false
        outletNewValue.delegate = self
        outletNewKey.delegate = self
        outletWindow.title = "Add metadata"
    }
    /// This method is called when the user attempts to submit a new add. It adds the metadata to the static
    /// "currentlySelectedFile" variable of the View Controller.
    /// - Parameters:
    /// - sender: The button that was clicked.
    @IBAction func submitClicked(_ sender: NSButton) {
        ViewController.currentlySelectedFile?.metadata.append(Metadata(keyword: outletNewKey.stringValue, value: outletNewValue.stringValue))
        closed = true
        outletWindow.close()
    }
    
    ///  This method is to deal with the add window closing. It updates the dictionary. and calls the reload function.
    /// - Parameters:
    /// - notification: The notification sent.
        func windowWillClose(_ notification: Notification){
            library.dictBuilder(key: (ViewController.currentlySelectedFile?.metadata.last!.keyword)!, value: (ViewController.currentlySelectedFile?.metadata.last!.value)!,file: ViewController.currentlySelectedFile!)
            addButton.isEnabled = true
            NotificationCenter.default.post(name: .reloadLibrary, object: nil)
            ViewController.currentlySelectedFile?.addDateModified()
        }

    /// This method is called whenever the text fields are modified and changes the state of the the add button from
    /// enabled to disbaled based on whether or not the add is allowed. It checks that the field aren't empty and that
    /// the metadata doesn't already exist.
    /// - Parameters:
    /// - obj: The notification sent
    override func controlTextDidChange(_ obj: Notification) {
        outletWarning.stringValue = ""
        if !(outletNewValue.stringValue == "") && !(outletNewKey.stringValue == ""){
            if outletNewKey.stringValue == "creator" {
                outletWarning.stringValue = "That keyword already exists, please change it or remove the existing metadata first."
                outletAddButton.isEnabled = false
                return
            }
            for metadataItem in (ViewController.currentlySelectedFile?.metadata)!{
                if metadataItem.keyword == outletNewKey.stringValue{
                    outletWarning.stringValue = "That keyword already exists, please change it or remove the existing metadata first."
                    outletAddButton.isEnabled = false
                    return
                }
            }
            outletAddButton.isEnabled = true
        }
        else{
            outletAddButton.isEnabled = false
        }
    }
}
