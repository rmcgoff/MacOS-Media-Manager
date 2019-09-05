//
//  DictionaryEditor.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 9/3/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation


// Class with a dictionary of string and file arrays, and methods to use to edit it
class DictionaryEditor{
    
    var dictionary = [String:[File]]()
    
    /// This function checks to see if a strings file array has a file in it.
    /// It will search take a string's file array in the dictionary (if it exists), then search the file array for
    /// a specific file, and return the index if it exists.
    ///
    /// - Parameters:
    /// - key: The term in the dictionary whose file array we want to search
    /// - file: The file to search for in the file array
    /// - return: The index of the file, nil if the file is not present
    final func dicFindElement(using key: String, find file: File)-> Int?{
        let arrayOfFiles = dictionary[key] ?? []
        for (fileIndex, matchingFile) in arrayOfFiles.enumerated(){
            if matchingFile == file{
                return fileIndex
            }
        }
        return nil
    }
    
    /// This function adds/updates a key and value string's file array with a new file.
    /// It will take a string's file array in the dictionary (if it exists), and add a file to it. It does this
    /// for two input strings (a key and a value). It also implements a check to make sure no duplicate files are allowed.
    ///
    /// - Parameters:
    /// - key: First string of the dictionary to add a file to
    /// - value: Second string of the dictionary to add a file to
    /// - file: The file to add to the string's file arrays
    final func dictBuilder(key: String, value: String, file: File){
        var keyList = dictionary[key] ?? []
        var valueList = dictionary[value] ?? []
        if dicFindElement(using: key, find: file) == nil{
            keyList.append(file)
            dictionary[key] = keyList
        }
        if dicFindElement(using: value, find: file) == nil{
            valueList.append(file)
            dictionary[value] = valueList
        }
    }
    
    /// This function removes a key and value from a files in a dictionary
    /// It will take a string's file array in the dictionary (if it exists), and remove the file from it. It does this
    /// for two input strings (a key and a value). It also implements a check to make sure no duplicate files are allowed.
    ///
    /// - Parameters:
    /// - key: First string of the dictionary to remove a file from
    /// - value: Second string of the dictionary to remove a file from
    /// - file: The file to remove from the string's file arrays
    final func dictRemover(key: String, value: String, file : MMFile){
        if let keyFiles = dictionary[key]{
            for (index,keyFile) in keyFiles.enumerated(){
                if keyFile == file as! File{
                    dictionary[key]?.remove(at: index)
                        if (dictionary[key]?.isEmpty)!{
                            dictionary.removeValue(forKey: key)
                        }
                    }
                }
            }
        if let valueFiles = dictionary[value]{
            for (index,valueFile) in valueFiles.enumerated(){
                if valueFile == file as! File{
                    dictionary[value]?.remove(at: index)
                    if (dictionary[value]?.isEmpty)!{
                        dictionary.removeValue(forKey: value)
                    }
                }
            }
        }
    }
}

