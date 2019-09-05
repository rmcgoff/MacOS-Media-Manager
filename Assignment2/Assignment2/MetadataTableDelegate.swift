//
//  MetadataTableDelegate.swift
//  Assignment2
//
//  Created by Jeremiah Kumar on 10/4/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Foundation
import AppKit

/// This is a delegate class to handle events from the metadata table
class MetadataTableDelegate: NSObject, NSTableViewDelegate{
    var minusButton : NSButton!
    var mutableSelection : Int
    
    /// init setting the stored variables to be the given variables
    init(minusButton: NSButton!, mutableSelection: Int){
        self.minusButton = minusButton
        self.mutableSelection = mutableSelection
    }
    
    ///  This method deals with the visibility of the minus button when the user selects a row in the table.
    /// If the row is beyond the mutable selection (non editable data) we disable the button, otherwise it can be enabled.
    /// - Parameters:
    /// - tableView: the table view calling the method
    /// - row: the int representation of the selected row
    func tableView(_ tableView: NSTableView,
                   shouldSelectRow row: Int) -> Bool{
        if row >= mutableSelection{
            minusButton.isEnabled = false
        }
        else{
            minusButton.isEnabled = true
        }
        return true
    }
    
    ///  This method deals with the editability of a row the user has selected.
    ///  If the row is beyond the mutable selection (non editable data) we disable editing, otherwise it can be enabled.
    /// - Parameters:
    /// - tableView: the table view calling the method
    /// - row: the int representation of the selected row
    /// - Returns:
    /// - bool true if the row can be edited, false if not.
    func tableView(_ tableView: NSTableView, shouldEdit tableColumn: NSTableColumn?,
                   row: Int) -> Bool{
        if row >= mutableSelection{
            return false
        }
        else{
            return true
        }
    }
}
