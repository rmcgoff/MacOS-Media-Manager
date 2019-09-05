//
//  BookmarkDelegate.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 10/3/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Foundation
import AppKit


/// This is a delegate class to handle events from the Bookmark table
class BookmarkTableDelegate: NSObject, NSTableViewDelegate{
    
    /// This method is called when users attempt to edit the table, and asks us if we should allow it.
    /// We want this table to not be editable so we simply return false.
    /// - Parameters:
    /// - tableView: The tableView calling this method.
    /// - tableColumn: The column being edited
    /// - row: The row being edited
    /// - Returns:
    /// - An Bool representing if the editing is allowed.
    ///
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?,
                   row: Int) -> Bool{
            return false
    }
}
