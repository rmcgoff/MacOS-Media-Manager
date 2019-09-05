//
//  CollectionToJSON.swift
//  MediaLibraryManager
//
//  Created by Ryan McGoff on 8/25/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class CollectionToJSON: MMFileExport{
    
    ///
    /// Constructs JSON data object by creating a dictionary for each files metdata, and appending all dictionaries
    /// to an array. This array is then passed to JSONSerialization's data function and then written to the given file path.
    /// - Parameters:
    /// - filename: the file to write export to
    /// - items: a MMFILE array of files
    /// - Throws: thrown when JSONSerialization's write method fails
    ///
    func write(filename: String, items: [MMFile]) throws {
        
        let path = NSString(string: filename).expandingTildeInPath
        let pathAsURL = URL(fileURLWithPath: path)
        var fileArray = [NSDictionary]()
        
        for file in items {
            if let fileToExport = file as? File{
                let fileAsdic = fileToExport.convertToDic()
                fileArray.append(fileAsdic)
            }
        }
        let jsonData = try JSONSerialization.data(withJSONObject: fileArray, options: .prettyPrinted)
        do{
            try jsonData.write(to: pathAsURL)
        }
        catch{
            throw MMCliError.failedJsonWrite
        }
        }
    }
