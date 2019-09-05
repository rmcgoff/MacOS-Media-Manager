//
//  CollectionViewItem.swift
//  Assignment2
//
//  Created by Ryan McGoff on 9/19/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa

/// This class represents out custom CollectionViewItem.
class CollectionViewItem: NSCollectionViewItem {
    
    ///Overrides the isSelected super method to add a call to our custom color update class.
    override var isSelected: Bool {
        didSet{
            super.isSelected = isSelected
            updateColor()
        }
    }

    @IBOutlet weak var outletImage: NSImageView!
    @IBOutlet weak var outletLabel: NSTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    ///
    /// Based onthe highlight state of the item, this method uses a switch statement to appropriately
    /// update the collectionViewItem's background color.
    ///
    func updateColor(){
        if isSelected{
            
        switch highlightState{
        case .none:
            view.layer?.backgroundColor = NSColor.clear.cgColor
            break;
        case .forSelection:
            view.layer?.backgroundColor = NSColor.lightGray.cgColor
            break;
        default:
            break;
            }
        }
        else{
            view.layer?.backgroundColor = NSColor.clear.cgColor
        }
    }
    
}
