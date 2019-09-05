//
//  Media.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/8/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// The Document class is a subclass of File and holds variables that are specific/required of a document media type.
class Document : File {
   // var bookmarks = ["Document"]
    
    /// Initalises a Document object, because there are no document specific metadata it passes all the data to the File super class
    override init(filename: String, path: String, metadata: [MMMetadata], creator: String, notes: String) {
        super.init(filename: filename, path: path, metadata: metadata, creator : creator, notes: notes)
        self.bookmarks.append("Document")
    }
    
    ///
    /// Overides File's convertToDic method, providing a Document specific dictionary of metadata.
    /// This is Used by CollectionTOJSON to get each file into JSON format for exporting.
    /// First it calls the superclass's convertMetaDataToDic method to retrieve the metadata as a dictionary,
    /// and constructs a new dictionary holding this metadata and other file properties for exporting.
    /// and then constructs a new dictionary holding for the JSON-SAVE commands.
    /// - Returns:
    /// A NSDictionary of all the Document file's data for exporting
    ///
    override func convertToDic()-> NSDictionary{
        
        var dic = convertMetaDataToDic()
        dic["creator"] = creator
        
        return[
            "fullpath": path as AnyObject,
            "type": "document" as AnyObject,
            "metadata": dic as AnyObject,
            "notes": notes as AnyObject
        ]
    }
}

/// The Image class is a subclass of File and holds variables that are specific/required of a Image media type.
class Image : File {
    var resolution : String
    //var bookmarks = ["Image"]
    
    // Initalises a Image object with the given resoultion data and passes the rest of the data to the File super class
    init(filename: String, path: String, metadata: [MMMetadata], creator: String, resolution : String, notes: String) {
        self.resolution = resolution
        super.init(filename: filename, path: path, metadata: metadata, creator : creator, notes: notes)
        self.bookmarks.append("Image")
    }

    ///
    /// Overides File's convertToDic method, providing a Image specific dictionary of metadata.
    /// This is Used by CollectionTOJSON to get each file into JSON format for exporting.
    /// First it calls the superclass's convertMetaDataToDic method to retrieve the metadata as a dictionary,
    /// and constructs a new dictionary holding this metadata and other Image properties for exporting.
    /// and then constructs a new dictionary holding for the JSON-SAVE commands.
    /// - Returns:
    /// A NSDictionary of all the Image file's data for exporting
    ///
    override func convertToDic()-> NSDictionary{
        
        var dic = convertMetaDataToDic()
        dic["creator"] = creator
        dic["resolution"] = resolution
        
        return[
            "fullpath": path as AnyObject,
            "type": "image" as AnyObject,
            "metadata": dic as AnyObject,
            "notes": notes as AnyObject
        ]
    }
    
}
/// The Audio class is a subclass of File and holds variables that are specific/required of a Audio media type.
class Audio : File {
    
    var runtime : String
    //var bookmarks = ["Audio"]
    
    // Initalises a Audio object with the given runtime data and passes the rest of the data to the File super class
    init(filename: String, path: String, metadata: [MMMetadata], creator: String, runtime : String, notes: String) {
        self.runtime = runtime
    super.init(filename: filename, path: path, metadata: metadata, creator : creator, notes: notes)
        self.bookmarks.append("Audio")
    }
    
    ///
    /// Overides File's convertToDic method, providing a Audio specific dictionary of metadata.
    /// This is Used by CollectionTOJSON to get each file into JSON format for exporting.
    /// First it calls the superclass's convertMetaDataToDic method to retrieve the metadata as a dictionary,
    /// and constructs a new dictionary holding this metadata and other Audio properties for exporting.
    /// and then constructs a new dictionary holding for the JSON-SAVE commands.
    /// - Returns:
    /// A NSDictionary of all the Audio file's data for exporting
    ///
    override func convertToDic()-> NSDictionary {
        
        var dic = convertMetaDataToDic()
        dic["creator"] = creator
        dic["runtime"] = runtime
        
        return[
            "fullpath": path as AnyObject,
            "type": "audio" as AnyObject,
            "metadata": dic as AnyObject,
            "notes": notes as AnyObject
        ]
    }
}

/// The Video class is a subclass of File and holds variables that are specific/required of a Video media type.
class Video : File {
    
    var runtime : String
    var resolution : String
    
    // Initalises a Video object with the given runtime & resolution data and passes the rest of the data to the File super class
    init(filename: String, path: String, metadata: [MMMetadata], creator: String, resolution : String, runtime : String, notes: String) {
        self.resolution = resolution
        self.runtime = runtime
    super.init(filename: filename, path: path, metadata: metadata, creator : creator, notes: notes)
        self.bookmarks.append("Video")
    }

    ///
    /// Overides File's convertToDic method, providing a Video specific dictionary of metadata.
    /// This is Used by CollectionTOJSON to get each file into JSON format for exporting.
    /// First it calls the superclass's convertMetaDataToDic method to retrieve the metadata as a dictionary,
    /// and constructs a new dictionary holding this metadata and other Video properties for exporting.
    /// and then constructs a new dictionary holding for the JSON-SAVE commands.
    /// - Returns:
    /// A NSDictionary of all the Video file's data for exporting
    ///
    override func convertToDic()-> NSDictionary{
        
        var dic = convertMetaDataToDic()
        dic["creator"] = creator
        dic["resolution"] = resolution
        dic["runtime"] = runtime
        
        return[
            "fullpath": path as AnyObject,
            "type": "video" as AnyObject,
            "metadata": dic as AnyObject,
            "notes": notes as AnyObject
        ]
    }
}
