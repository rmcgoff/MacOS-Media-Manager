//
//  AppDelegate.swift
//  Assignment2
//
//  Created by Ryan McGoff on 9/19/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

/// This class is the appDelegate for our application.
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBAction func addBookmarkClicked(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .addBookmark, object: nil)
    }
    
    @IBAction func openClicked(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .load, object: nil)
    }
    
    @IBAction func saveClicked(_ sender: NSMenuItem) {
        NotificationCenter.default.post(name: .save, object: nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

