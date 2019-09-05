//
//  dataSource.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 9/25/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Foundation
import AppKit

/// This class represents the datasource object for our collection and has methods to appropriately select and load data.
class dataSource: NSObject, NSCollectionViewDataSource{
    let collection = Collection()
    var collectionNo = 0

    /// This method takes a given path in an array and attempts to load it using the LoadCommand class. If successful,
    /// the command executes which loads the data into the collection variable and updates the appropriate variables.
    /// - Parameters:
    /// - path: The string path representing the json file to load.
    func loadData (path: [String]) {
        let load = LoadCommand(params: path, library: collection);
        do {
            try load.execute();
            collectionNo = collection.library.count
        }
        catch{
            //Only printed if the JSON has syntax errors
            print ("Could not load this file, please make sure it is an appropriate JSON")
        }
    }

    /// This is a NSCollectionViewDataSource method that is needed to find the size of the collection for item creation.
    /// - Parameters:
    /// - collectionView: The collectionView calling this method.
    /// - section: The number of items in the section.
    /// - Returns:
    /// - An Int representing the size of the collection.
    ///
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionNo
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
    
    
    /// This is a NSCollectionViewDataSource method that is used to create a collectionViewItem for the collection.
    /// First it finds the right file in the library using the indexpath and then creates a CollectionViewItem for it.
    /// If it is an image the method creates and resizes the image appropriately and adds that to the imageview portion
    /// of the collectionview item. If it isn't, the icon of the file is used instead. The filename is added as well and
    /// then the collectionViewItem is complete and ready to be returned.
    /// - Parameters:
    /// - collectionView: The collectionView calling this method.
    /// - indexPath: The index path of the item to be created.
    /// - Returns:
    /// - The collectionViewItem to be used.
    ///
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let iterator = indexPath.item
        let filename = collection.library[iterator].filename
        let path = collection.library[iterator].path
        let workspace = NSWorkspace.shared
        let icon = workspace.icon(forFile: path)
        
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"), for: indexPath) as! CollectionViewItem

        if collection.library[iterator] is Image{
            let image = NSImage(contentsOfFile: path)!
            let resizedImage = resize(image: image, w: Int(item.outletImage.frame.size.width), h: Int(item.outletImage.frame.size.height))
            item.outletImage.image = resizedImage
        }
        else{
            item.outletImage.image = icon
        }
        
        item.outletLabel.stringValue = filename
        return item
    }
}

