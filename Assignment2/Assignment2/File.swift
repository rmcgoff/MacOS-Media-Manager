//
//  File.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/6/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

///This class represents a File for the MMCollection
class File : MMFile{
    
    var filename: String
    var path: String
    var metadata: [MMMetadata]
    var creator : String
    var notes = ""
    var bookmarks = [String]()
  
    /// Creates a new file with given name, path, creator and array of metadata
    init(filename: String, path: String, metadata: [MMMetadata], creator: String, notes: String) {
        self.filename = filename
        self.path = path
        self.metadata = metadata
        self.creator = creator
        self.notes = notes
    }
    
    var description: String {
        return "\(filename)"
        }
    
    ///
    /// Converts a files metadata into a Dictionary
    /// Returns:
    /// - The metadata converted into the dictionary
    ///
    final func convertMetaDataToDic() -> Dictionary<String,String>{
        var metadataDic = [String:String]()
        for data in metadata{
            metadataDic[data.keyword] = data.value
        }
        return metadataDic
    }
    
    func dateToString()-> String{
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    func addDateModified(){
        self.metadata.append(Metadata(keyword: "date-modified", value: dateToString()))
    }
    
    ///
    /// Abstract method for children to implement. Will return an NSDictionary in the required JSON format
    /// Return:
    /// - The NSdictionary
    ///
    func convertToDic()-> NSDictionary{
        preconditionFailure("All media types MUST have a convertToDictionary method")
    }
    
    ///
    /// Function to allow == operator between Files, comapres path (unique identifier)
    /// Returns:
    /// - True if they are equal, else false
    static func == (lhs: File, rhs: File) -> Bool {
        return lhs.path == rhs.path
    }
    ///
    /// Function to allow != operator between Files using ==
    /// Returns:
    /// - True if they are equal, else false
    static func !=(lhs: File, rhs: File) -> Bool{
        return !(lhs == rhs)
    }
}

