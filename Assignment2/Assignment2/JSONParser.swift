//
//  JSONParser.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/14/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

//The JSONParser class reads a JSON file and constructs a MMFile array representing a media collection using the data from the JSON file.
class JSONParser:  FileCreator,MMFileImport{
    var log = ""
    
    ///
    /// Reads a given file and attempts to extract JSON data from it to create a collection of media files.
    /// The function creates a dictionary holding each file and their metadata, and calls the CheckLoad function to check
    /// the file for errors and to construct an appropriate file object for the collection [MMFile]. After the file has been returned,
    /// dictonaryBuilder adds the values and keys in the file's metadata to a dictionary with an associated filename as a value (so search can be more efficent).
    /// - Parameters:
    /// - filename: the file to read/extract JSON data from
    /// - Returns:
    /// -A MMFILE array of files, representing a media collection
    /// - Throws: thrown when JSONSerialization's read method fails
    ///
    func read(filename: String) throws -> [MMFile]{
        var collection = [File]()
        var unsuccessfulItemCount = 0
        let path = NSString(string: filename).expandingTildeInPath
        let url = URL(fileURLWithPath: path)
        
        do {
            let JSONdata = try Data(contentsOf: url)
            let JSONobject = try JSONSerialization.jsonObject(with: JSONdata, options: .allowFragments)
            
            if let JSONdictionary = JSONobject as? [[String:Any]]{
                var index = 0
                for file in JSONdictionary{
                    if let newFile = try checkAndLoad(file: file, at: index){
                        collection.append(newFile)
                        log.append("\nFile: \(newFile.filename) at index \(index) has been succesfully added to the collection\n")
                        updateListDictionaryWith(file: newFile)
                    }
                    index+=1
                }
                unsuccessfulItemCount = JSONdictionary.count - collection.count
            }
        } catch {
            print(error.localizedDescription)
            throw MMCliError.unableToLoad
        }
        
        if unsuccessfulItemCount == 0{
            log = "For \(filename),\n All \(collection.count) items were added successfully!\n"
        }
        else{
            log.append("For \(filename),\n\nSummary:\n Number of successful items = \(collection.count)")
            log.append("\n Number of failed items = \(unsuccessfulItemCount)")
        }
        return collection
    }
}
