//
//  Collection.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/7/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

extension MMMetadata {
    // note the 'self' in here
    static func == (lhs: Self, rhs: MMMetadata) -> Bool {
        return lhs.keyword == rhs.keyword && lhs.value == rhs.value
    }
    
    static func !=(lhs: Self, rhs: MMMetadata) -> Bool{
        return !(lhs == rhs)
    }
}


//A class to house the file collection and provide methods to interact with it.
class Collection : DictionaryEditor, MMCollection, NSCopying {
   
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Collection(collection: library)
        copy.dictionary = dictionary
        return copy
    }
    
    
    var library : [MMFile]

    ///
    /// Adds a file's metadata to the media metadata collection.
    ///
    /// - Parameters:
    /// - file: The file and associated metadata to add to the collection
    func add(file: MMFile){
        library.append(file)
        for item in file.metadata{
            dictBuilder(key: item.keyword, value: item.value, file: file as! File)
        }
    }
    
    
    ///
    /// Adds a specific instance of a metadata, to a specific file in the collection. Updates the date modified field as well.
    /// Goes through each file in the library until it finds the right one. Append the metadata and then update the library
    /// (using a temporary file which is a copy of the current file) and dictionary.
    ///
    /// - Parameters:
    /// - metadata: The item to add to the collection
    func add(metadata: MMMetadata, file: MMFile){
        var fileToChange : MMFile
        for (index,eachFile) in library.enumerated(){
            fileToChange = eachFile
             fileToChange.metadata.append(Metadata(keyword: "date-modified", value: dateToString()))
            if eachFile as! File == file as! File{
                fileToChange.metadata.append(metadata)
                library[index] = fileToChange
                dictBuilder(key: metadata.keyword, value: metadata.value, file: file as! File)
                break
            }
        }
    }
   
    ///
    /// Removes a specific instance of a metadata from the collection.
    /// Goes through each file in the library and first checks if the files metadata contains the requested removal data. If it does,
    /// remove the right metadata (using a temporary file) and update the library.
    ///
    /// - Parameters:
    /// - metadata: The item to remove from the collection
    func remove(metadata: MMMetadata){
        for (fileIndex,file) in library.enumerated() {
            if file.metadata.contains(where: {
                if $0 as! Metadata == metadata as! Metadata{
                    return true
                }
                return false
            }){
                var tempFile = file
                for (metaDataIndex,fileMetadata) in tempFile.metadata.enumerated(){
                    if fileMetadata as! Metadata == metadata{
                        tempFile.metadata.remove(at: metaDataIndex)
                        library[fileIndex] = tempFile
                    }
                }
            }
        }
    }
    
    ///
    /// Removes a specific instance of a metadata (given its keyword) from the collection and updates dictionary as well.
    /// Goes through each file in the library and first checks if the files metadata contains the requested removal data. If it does,
    /// remove the right metadata (using a temporary file), update the library and update the date modified field. After words, go to the
    /// dictionary and update the relvant strings.
    ///
    /// - Parameters:
    /// - key: The keyword of the metadata to remove
    /// - file: The file to remove the metadata from
    func remove(key: String, file: MMFile){
        var fileToChange : MMFile
        var value = ""

        for (index,eachFile) in library.enumerated(){
            fileToChange = eachFile
            if eachFile as! File == file as! File{
                for (mdindex,item) in fileToChange.metadata.enumerated(){
                    if (item.keyword.caseInsensitiveCompare(key) == ComparisonResult.orderedSame){
                        value = item.value
                        fileToChange.metadata.remove(at: mdindex)
                        fileToChange.metadata.append(Metadata(keyword: "date-modified", value: dateToString()))
                        break
                    }
                }
                library[index] = fileToChange
                dictRemover(key: key, value: value, file: file)
//                if let keyFiles = dictionary[key]{
//                    for (index,keyFile) in keyFiles.enumerated(){
//                        if keyFile == file as! File{
//                            dictionary[key]?.remove(at: index)
//                            if (dictionary[key]?.isEmpty)!{
//                                dictionary.removeValue(forKey: key)
//                            }
//                        }
//                    }
//                }
//                if let valueFiles = dictionary[value]{
//                    for (index,valueFile) in valueFiles.enumerated(){
//                        if valueFile == file as! File{
//                            dictionary[value]?.remove(at: index)
//                            if (dictionary[value]?.isEmpty)!{
//                                dictionary.removeValue(forKey: value)
//                            }
//                        }
//                    }
//                }
            }
        }
    }
    
    ///
    /// Finds all the files associated with the keyword.
    /// Takes care of media type specific search terms first, appending the correct files. Otherwise, perform a normal search comparing case
    /// insensitivily.
    ///
    /// - Parameters:
    /// - term: The keyword to search for
    /// - Returns:
    /// A list of all the metadata associated with the keyword, possibly an empty list.
    func search(term: String) -> [MMFile]{
        print("method called")
        var searchResults = [MMFile]()
        if term == "creator" {
            searchResults = library
        }
        
        else if term == "resolution"{
            for file in library{
            if let image = file as? Image{
                searchResults.append(image)
            }
            if let video = file as? Video{
                searchResults.append(video)
            }
        }
        }
        else if term == "runtime"{
            for file in library {
                if let audio = file as? Audio{
                    searchResults.append(audio)
                }

                if let document = file as? Video{
                    searchResults.append(document)
                }
            }
        }
        else{
            print(dictionary)
            for value in dictionary{
                print(value.key)
                print(term)
                if(value.key.caseInsensitiveCompare(term) == ComparisonResult.orderedSame){
                    searchResults = value.value
                }
            }
        }
        if searchResults.isEmpty{
            print ("There are no files that have this associated search term")
        }
        return searchResults
    }
    
    ///
    /// Finds all the files of a certain type.
    /// Checks all the files type against the search term to return all the requested file types.
    ///
    /// - Parameters:
    /// - type: The type the search for
    /// - Returns:
    /// A list of all the metadata associated with the keyword, possibly an
    /// empty list.
    func search(type:String)->[MMFile]{
        var searchResults = [MMFile]()
        
        if type == "All"{
            searchResults = library
        }
        
        for file in library{
            if let audio = file as? Audio {
                if audio.bookmarks.contains(type){
                searchResults.append(file)
                }
            }
            if let image = file as? Image {
                if image.bookmarks.contains(type){
                    searchResults.append(file)
                }
            }
            if let video = file as? Video {
                if video.bookmarks.contains(type){
                    searchResults.append(file)
                }
            }
            if let document = file as? Document {
                if document.bookmarks.contains(type){
                    searchResults.append(file)
                }
            }
        }

        return searchResults
    }
    
    ///
    /// Returns a list of all the files in the index
    ///
    /// - Parameters:
    /// - Returns:
    /// A list of all the files in the index, possibly an empty list.
    func all() -> [MMFile]{
        return library
    }
    
    ///
    /// Finds all the metadata associated with the keyword of the item
    ///
    /// - Parameters:
    /// - item: The item to search for.
    /// - Returns:
    /// A list of all the metadata associated with the item's keyword, possibly an empty list.
    func search(item: MMMetadata) -> [MMFile]{
        let keyword = item.keyword
        let results = dictionary[keyword] ?? []
        return results
    }
    
    ///
    /// Gets the current date and converts it to a String.
    ///
    /// - Parameters:
    /// - Returns:
    /// The current date as a String
    func dateToString()-> String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    var description: String{
        guard self.library.count > 0 else{
            return "The Collection is empty"
        }
        var log = ""
        for (i,file) in self.library.enumerated() {
            log.append("\(i): \(file)")
        }
        return log
    }
    /// Constructs a new collection with a given library.
    init(collection: [MMFile]) {
        self.library = collection
        super.init()
    }
    /// Constructs a new collection with an empty library.
    override init() {
        self.library = [MMFile]()
        super.init()
    }
}
