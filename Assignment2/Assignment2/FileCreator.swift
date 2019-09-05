//
//  FileCreator.swift
//  MediaLibraryManager
//
//  Created by Ryan McGoff on 9/3/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

// Class with methods to create files, inherits from dictionaryEditor as classes that create files must edit dictionaries
class FileCreator: DictionaryEditor{
    
    ///
    /// The function checks the shared metadata requriments (like file path) for each file
    /// and then calls a specific method to check for file type specific requirments (like resoultion/runtime) and return an initialised file object.
    /// The function checks into their own variables (as these are values  stored in the File parent class)
    /// - Parameters:
    /// - file: a dictionary holding all of the file's metadata
    /// - index of the file in relation to the JSON data file, used for error messages
    /// - Returns:
    /// - the newly created File
    ///
    func updateListDictionaryWith(file: File){
        dictBuilder(key: "creator", value: file.creator, file: file)
        for metadataItem in file.metadata{
            dictBuilder(key: metadataItem.keyword, value: metadataItem.value, file: file)
        }
        if let audio = file as? Audio {
            
            dictBuilder(key: "runtime", value: audio.runtime, file: file)
        }
        if let image = file as? Image {
            dictBuilder(key: "resolution", value: image.resolution, file: file)
        }
        if let video = file as? Video {
            dictBuilder(key: "runtime", value: video.runtime, file: file)
            dictBuilder(key: "resolution", value: video.resolution, file: file)
        }
        //adds current date to file's metadata
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "dd-MMM-yyyy"
        let dateString = formatter.string(from: now)
        file.metadata.append(Metadata(keyword: "date-added", value: dateString))
    }
    
    ///
    /// The function checks the shared metadata requriments (like file path) for each file
    /// and then calls a specific method to check for file type specific requirments (like resoultion/runtime) and return an initialised file object.
    /// The function checks into their own variables (as these are values  stored in the File parent class)
    /// - Parameters:
    /// - file: a dictionary holding all of the file's metadata
    /// - index of the file in relation to the JSON data file, used for error messages
    /// - Returns:
    /// - the newly created File
    /// - Throws:
    /// - If there is missing requried metadata
    ///
    func checkAndLoad(file: [String:Any],at index: Int) throws ->File?{
        // Get file type & path
        let fileType = file["type"] as! String
        let filePath = file["fullpath"] as! String
        var notes = ""
        if file.contains(where: {
            if $0.key == "notes"{
                return true
            }
            return false
        }){
            notes = file["notes"] as! String
        }
        // Get file name
        let filePathSplit = filePath.components(separatedBy: "/")
        let filename = filePathSplit[filePathSplit.endIndex-1];
        
        // Checks if metadata exists
        guard let metaData = file["metadata"]else{
            print("\nFAILURE: no metadata for file at index\(index)")
            return nil
        }
        
        // Creates a meta data dictionary
        var metaDataDic = metaData as! [String:String]
        
        // Check for creator field for all file types
        guard let creator = metaDataDic["creator"] else{
            print("\nFAILURE no creator metadata for \(fileType) file at index \(index)")
            return nil
        }
        if creator.isEmpty{
            print("\nFAILURE for \(fileType) file at index \(index),creator metadata can't be empty")
            return nil
        }
        
        // Removes creator for all types, as this is stored in its own varaible now
        metaDataDic.removeValue(forKey: "creator")
        
        // Checks file to see if it passes its file type's specific requirments, then loads it
        switch(fileType){
        case "image":
            return createImage(with: metaDataDic, at: index, filename: filename, filePath: filePath, creator: creator, notes: notes)
        case "document":
            return createDocument(with: metaDataDic, filename: filename, filePath: filePath, creator: creator, notes: notes)
        case "video":
            return createVideo(with: metaDataDic, at: index, filename: filename, filePath: filePath, creator: creator, notes: notes)
        case "audio":
            return createAudio(with: metaDataDic, at: index, filename: filename, filePath: filePath, creator: creator, notes: notes)
        default:
            print("\nFAILURE The file type \(fileType) is neither a video, image or a document")
            return nil
        }
    }
    
    ///
    /// The function is called to convert a file's metdata dictionary to an array of Metadata objects
    /// - Parameters:
    /// - metaDataDic: the metadata dictionary to use
    /// - Returns:
    /// - the metadata dictionary as an Metadata array
    ///
    func convertDicToArrayUsing(metaDic:[String:String])-> [Metadata]{
        var metadataArray = [Metadata]()
        
        for (key, value) in metaDic {
            metadataArray.append(Metadata(keyword: key, value: value))
        }
        return metadataArray
    }
    
    ///
    /// The function is called to create a Image object, checking for video specific Metadata requirments before initialising the new object.
    /// The function first checks to make sure the requested Image file has resoultion data before initialising the new object
    /// - Parameters:
    /// - metaDataDic: the metadata to use when creating the Image File
    /// - index of file in relation to the JSON data file, used for error messages
    /// -filename: the filename to use when creating the Image File
    /// -filePath: the filepath to use when creating the Image File
    /// -creator: the creator metadata to use when creating the Image File
    /// - Returns:
    /// - the newly created Video File object
    ///
    func createImage(with metaDataDic: [String:String], at index: Int,filename:String,filePath:String,creator:String,notes:String)->Image?{
        var metaDataDic = metaDataDic
        guard let resolution = metaDataDic["resolution"] else{
            print("\nFAILURE no resolution metadata for image file at index \(index)")
            return nil
        }
        
        if resolution.isEmpty{
            print("\nFAILURE for Image file at index \(index), resolution metadata can't be empty")
            return nil
        }
        metaDataDic.removeValue(forKey: "resolution")
        let metaData = convertDicToArrayUsing(metaDic: metaDataDic)
        return (Image(filename: filename, path: filePath, metadata: metaData, creator: creator, resolution: resolution, notes: notes))
        
    }
    
    ///
    /// The function is called to create a Video object, checking for video specific Metadata requirments before initialising the new object.
    /// The function first checks to make sure the requested Video file has resoultion,runtime data initialising the new object.
    /// - Parameters:
    /// - metaDataDic: the metadata to use when creating the Video File
    /// -filename: the filename to use when creating the Video File
    /// - index of file in relation to the JSON data file, used for error messages
    /// -filePath: the filepath to use when creating the Video File
    /// -creator: the creator metadata to use when creating the Video File
    /// - Returns:
    /// - the newly created Video File object
    ///
    func createVideo(with metaDataDic: [String:String], at index: Int, filename:String,filePath:String,creator:String,notes:String)->Video?{
        var metaDataDic = metaDataDic
        
        guard let resolution = metaDataDic["resolution"]else{
            print("\nFAILURE no resolution metadata for video file at index \(index)")
            return nil
        }
        guard let runtime = metaDataDic["runtime"] else{
            print("\nFAILURE no runtime metadata for video file at index \(index)")
            return nil
        }
        
        if resolution.isEmpty || runtime.isEmpty{
            print("\nFAILURE for video file at index \(index), runtime and resolution metadata can't be empty")
            return nil
        }
        
        metaDataDic.removeValue(forKey: "resolution")
        metaDataDic.removeValue(forKey: "runtime")
        let metaData = convertDicToArrayUsing(metaDic: metaDataDic)
        return (Video(filename: filename, path: filePath, metadata: metaData, creator: creator, resolution: resolution, runtime: runtime, notes: notes))
        
    }
    
    ///
    /// The function is called to create a Audio object, checking for audio specific Metadata requirments before initialising the new object.
    /// - Parameters:
    /// - metaDataDic: the metadata to use when creating the Audio File
    /// - index of file in relation to the JSON data file, used for error messages
    /// -filename: the filename to use when creating the Audio File
    /// -filePath: the filepath to use when creating the Audio File
    /// -creator: the creator metadata to use when creating the Audio File
    /// - Returns:
    /// - the newly created Audio File object
    ///
    func createAudio(with metaDataDic: [String:String],at index: Int, filename:String,filePath:String,creator:String,notes:String)->Audio?{
        var metaDataDic = metaDataDic
        
        guard let runtime = metaDataDic["runtime"] else{
            print("\nFAILURE no runtime metadata for audio file at index \(index)")
            return nil
        }
        if runtime.isEmpty{
            print("\nFAILURE for audio file at index \(index), runtime  metadata can't be empty")
            return nil
        }
        metaDataDic.removeValue(forKey: "runtime")
        let metaDataArray = convertDicToArrayUsing(metaDic: metaDataDic)
        return (Audio(filename: filename, path: filePath, metadata: metaDataArray, creator: creator, runtime: runtime, notes: notes))
        
    }
    ///
    /// The function is called to create a Document object.
    /// - Parameters:
    /// - metaDataDic: the metadata to use when creating the document
    /// -filename: the filename to use when creating the document
    /// -filePath: the filepath to use when creating the document
    /// -creator: the creator metadata to use when creating the document
    /// - Returns:
    /// - the newly created document object
    ///
    func createDocument(with metaDataDic: [String:String],filename:String,filePath:String,creator:String,notes:String)->Document?{
        let metaDataArray = convertDicToArrayUsing(metaDic: metaDataDic)
        return (Document(filename: filename, path: filePath, metadata: metaDataArray, creator: creator, notes: notes))
        
    }
}
