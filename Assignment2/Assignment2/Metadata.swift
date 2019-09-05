//
//  Metadata.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/6/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

/// This class represents a key value pair of metadata for a file.
class Metadata : NSObject, MMMetadata{
    @objc dynamic var keyword: String
    @objc dynamic var value: String
    
    override var description: String{
        return "\(keyword) : \(value)"
    }
    
    // Creates a new metadata object with a requested key and value.
    init(keyword: String, value : String) {
        self.keyword = keyword
        self.value = value
    }
    
}

