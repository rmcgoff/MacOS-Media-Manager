//
//  ContentWindow.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 10/1/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa
import AppKit
import AVKit
import Quartz




class ContentWindow: NSWindowController, NSTextFieldDelegate, NSWindowDelegate {
    
    @IBOutlet weak var outletImageView: NSImageView!
    @IBOutlet weak var outletNotes: NSTextField!
    @IBOutlet weak var outletVideo: AVPlayerView!
    @IBOutlet weak var outletPDF: PDFView!
    @IBOutlet weak var outletSoundPlayer: AVPlayerView!
    @IBOutlet var metadataController: NSArrayController!
    @IBOutlet weak var outletMetadataTable: NSTableView!
    @IBOutlet weak var outletTextViewContainer: NSScrollView!
    @IBOutlet var outletTextView: NSTextView!
    @IBOutlet var outletContentWindow: NSWindow!
    @objc dynamic var metadata = NSMutableArray()
    var notes: NSTextField!
    
    /// Initaliser that sets up the references to the notes and metadata values to use for the window.
    /// - Parameters:
    /// - notes: The notes to be used
    /// - metadata: The metadata to be used
    convenience init(notes: NSTextField!, metadata: NSMutableArray){
        self.init(windowNibName: NSNib.Name(rawValue: "ContentWindow"));
        self.notes = notes
        self.metadata = metadata
    }
    
    /// This method calls the super load method then sets the appropriate delegates and variable stats/values.
    override func windowDidLoad() {
        super.windowDidLoad()
        outletContentWindow.title = (ViewController.currentlySelectedFile?.path)!
        outletNotes.delegate = self
        outletContentWindow.delegate = self
        loadData()
    }
    
    /// This sends a notification to the Notification center that the next file has been requested, and reloads the data.
    /// - Parameters:
    /// - sender: The button that was clicked.
    @IBAction func nextClicked(_ sender: NSButton) {
        NotificationCenter.default.post(name: .reloadPanelWithNewFile, object: nil, userInfo: ["type": "next"])
        loadData()
    }
    
    /// This sends a notification to the Notification center that the previous file has been requested, and reloads the data.
    /// - Parameters:
    /// - sender: The button that was clicked.
    @IBAction func previousClicked(_ sender: NSButton) {
        NotificationCenter.default.post(name: .reloadPanelWithNewFile, object: nil, userInfo: ["type": "previous"])
        loadData()
    }
    
    /// This method updates the stored notes and metadata.
    /// - Parameters:
    /// - notes: The new notes to use
    /// - metadata: The new metadata button to use
    func newMetadataAndNotes(notes: NSTextField!, metadata: NSMutableArray){
        self.notes = notes
        self.metadata = metadata
    }
    
    /// This method takes an NSimage and resizes it to a given width or height.
    /// - Parameters:
    /// - image: The image the be resized.
    /// - w: The width to resize to.
    /// - h: The height to resize to.
    /// - Returns:
    /// - The resized NSImage.
    ///
    func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    /// This method loads data into the window outlets.
    /// It sets the default visibility of all outlets to hidden, then based on what type of data the file that was
    /// requested is, makes the appropriate outlet visible and loads the correct data.
    ///
    func loadData(){
        outletNotes.stringValue = notes.stringValue
        outletImageView.isHidden = true
        outletTextViewContainer.isHidden = true
        outletTextView.isHidden = true
        outletPDF.isHidden = true
        outletVideo.isHidden = true
        outletSoundPlayer.isHidden = true
        outletContentWindow.minSize = ((NSSize(width: 600, height: 500)))
        
        if ViewController.currentlySelectedFile! is Image{
            let image = NSImage(contentsOfFile: ViewController.currentlySelectedFile!.path)!
            let resizedImage = resize(image: image, w: Int(outletImageView.frame.size.width), h: Int(outletImageView.frame.size.height))
            outletImageView.image = resizedImage
            outletImageView.isHidden = false
        }
        if ViewController.currentlySelectedFile! is Document{
            print (ViewController.currentlySelectedFile!.filename)
            let stringArray = ViewController.currentlySelectedFile!.filename.components(separatedBy: ".")
            let type = stringArray[1]
            if type == "pdf"{
                outletPDF.isHidden = false
                let url = URL(fileURLWithPath: ViewController.currentlySelectedFile!.path)
                if let document = PDFDocument(url: url) {
                    outletPDF.document = document
                }
            }
            else if type == "txt"{
                outletTextView.isHidden = false
                outletTextView.isEditable = true
                outletTextViewContainer.isHidden = false
                    do {
                        let contents = try String(contentsOfFile: ViewController.currentlySelectedFile!.path)
                        outletTextView.string = contents;
                        outletTextView.isEditable = false ;
                    } catch {
                        // contents could not be loaded }
                    }
            }
            else{
                let workspace = NSWorkspace.shared
                let icon = workspace.icon(forFile: ViewController.currentlySelectedFile!.path)
                outletImageView.isHidden = false
                outletImageView.image = icon
                return
            }
        }
        if ViewController.currentlySelectedFile! is Video{
            outletVideo.isHidden = false
            let fileURL = NSURL(fileURLWithPath: ViewController.currentlySelectedFile!.path);
            let playView = AVPlayer(url: fileURL as URL);
            outletVideo.player = playView;
        }
        if ViewController.currentlySelectedFile! is Audio{
            outletSoundPlayer.isHidden = false
            let fileURL = NSURL(fileURLWithPath: ViewController.currentlySelectedFile!.path);
            let soundView = AVPlayer(url: fileURL as URL);
            outletSoundPlayer.player = soundView
        }
    }
    
    
    /// This is a window delegate method. This method is called when the window is about to close and content
    /// sends a notification with the title (filepath) of the window to the notification center.
    /// - Parameters:
    /// - sender: The window that is closing.
    /// - Returns:
    /// - Bool representing if we want to allow the window to close (always yes)
    ///
    func windowShouldClose(_ sender: NSWindow) -> Bool{
        NotificationCenter.default.post(name: .windowThatClosed, object: nil, userInfo: ["info": sender.title])
        return true
    }
    
    
    /// This method is called whenever the notes field is modified and reflects that change in the file
    /// - Parameters:
    /// - obj: The notification sent
    override func controlTextDidChange(_ obj: Notification) {
        ViewController.currentlySelectedFile?.notes = outletNotes.stringValue
    }
        

    

    
}
