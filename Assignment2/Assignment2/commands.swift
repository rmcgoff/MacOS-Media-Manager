//
//  commands.swift
//  MediaLibraryManager
//
//  Created by Paul Crane on 15/08/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//
import Foundation

/// This protocol specifies the new 'Command' pattern, and is more
/// Object Oriented.
protocol MMCommand{
    var results: MMResultSet? {get}
    func execute() throws
}

//Commaned Handler to handle Load command
class LoadCommand: MMCommand{
    var results: MMResultSet? = nil
    var library : Collection
    var files : [String]
    
    /// Creates a new LoadCommand with parameters and the Collection to load into
    init(params: [String], library: Collection){
        self.files = params
        self.library = library
    }
    
    ///
    /// For each file specified in the parameter, this function uses a parser to try to load in the files, printing the parser log to give the
    /// user appropriate information. After this process, it sets the collections library and adds all the files to the library.
    ///
    func execute() throws{
        var finalFiles = [MMFile]()
        let parser = JSONParser()
        for loadFile in files{
            let succeededFiles = try parser.read(filename: loadFile)
            finalFiles += succeededFiles
            print(parser.log)
        }
        
        library.dictionary = parser.dictionary
        for eachfile in finalFiles{
         library.add(file: eachfile)
        }
    }
}

/// Command handler to deal with the ListCommand
class ListCommand: MMCommand{
    var results: MMResultSet? = nil
    var library : Collection
    var searchTerm : [String]
    
    /// Creates a new ListCommand with a searchTerm and the collection to search
    init(searchTerm : [String], library: Collection){
        self.searchTerm  = searchTerm
        self.library = library
    }

    ///
    /// Sets results to a new MMResult set based on the collections search results
    ///
    func execute() throws{
        if searchTerm.isEmpty{
            results = MMResultSet(library.all())
        }
        else if searchTerm.count == 1{
            results = MMResultSet(library.search(term: searchTerm[0]))
        }
        else{
            throw MMCliError.invalidParameters
        }
    }
}

/// Command handler to deal with the ListTypeCommand
class ListTypeCommand:MMCommand{
    var results: MMResultSet?
    var library : Collection
    var searchType : [String]
    
    /// Creates a new ListTypeCommand with a searchType and the collection to search
    init(searchType: [String], library: Collection){
        self.searchType  = searchType
        self.library = library
    }
    
    ///
    /// Searches the collection for all of the type requested and sets results to this.
    /// Throws:
    /// - If list type is not one of the valid four.
    func execute() throws {
        if searchType.count != 1{
            throw MMCliError.requiredParameter
        }
        
        let searchTypeString = searchType[0].lowercased()
        let valuesArray = ["Image","Video","Audio","Document"]
        if valuesArray.contains(searchTypeString){
            results = MMResultSet(library.search(type: searchTypeString))
        }
        else{
            throw MMCliError.invalidListType
        }
    }
}

/// Command handler to deal with the AddCommand
class AddCommand: MMCommand{
    var results: MMResultSet? = nil
    var library : Collection
    var metadata : [String]
    var last : [MMFile]
    
    /// Creates a new AddCommand with a file to add to, metadata to add to it, and the collection to change
    init( metadata : [String], library: Collection, last : [MMFile]){
        self.library = library
        self.metadata = metadata
        self.last = last
    }
    ///
    /// Adds all metadata to the file, then adds the file to the collection, printing the appropriate messages and checking for special cases.
    /// Throws:
    /// - There is no metadata to add
    /// - If there isn't the right number of paramaters
    /// - If there is no result set
    /// - If the index is out of bounds
    /// - If the arguments are in the wrong format
    func execute() throws{
        if last.isEmpty{
            throw MMCliError.missingResultSet
        }
        if metadata.isEmpty{
            throw MMCliError.invalidParameters
        }
         if let index = Int(metadata[0]){
            metadata.removeFirst()
            guard metadata.count > 0 else {
                throw MMCliError.requiredParameter
            }
            guard metadata.count%2 == 0 else{
                throw MMCliError.wrongFormat
            }
            if index > (last.count-1) || index < 0{
                throw MMCliError.outOfBounds
            }
            let file = last[index]
            var iterator = 0
            while iterator != metadata.count{
                if metadata[iterator] == "creator" || metadata[iterator] == "runtime" || metadata[iterator] == "resolution"
                    || metadata[iterator] == "runtime" || metadata[iterator] == "date-created" || metadata[iterator] == "date-modified" {
                    print("\(metadata[iterator]) is a required metadata item for this file and will already exist. No duplicates are allowed")
                    iterator += 2
                    continue
                }
                let data = Metadata(keyword: metadata[iterator], value: metadata[iterator+1])
                library.add(metadata: data, file: file)
                print("Metadata with 'key : \(metadata[iterator]), value : \(metadata[iterator+1])' was added to file \(file.filename)")
                iterator += 2
            }
         }
         else{
            throw MMCliError.wrongFormat
        }
    }
}

/// Command handler to deal with the DeleteCommand
class DeleteCommand: MMCommand{
    var results: MMResultSet? = nil
    var last : [MMFile]
    var library : Collection
    var keys : [String]
    
    /// Creates a new Delete Command with a file to add from, metadata to delete from it, and the collection to change
    init(keys : [String], library: Collection, last: [MMFile]){
        self.library = library
        self.keys = keys
        self.last = last
    }

    ///
    /// Deletes all metadata from a file, printing the appropriate messages and checking for special cases.
    /// Throws:
    /// - There is no metadata to add
    /// - If there isn't the right number of paramaters
    /// - If there is no result set
    /// - If the index is out of bounds
    func execute() throws{
        if last.isEmpty{
            throw MMCliError.missingResultSet
        }
        if keys.isEmpty{
            throw MMCliError.invalidParameters
        }
        if let index = Int(keys[0]){
            keys.removeFirst()
            guard keys.count > 0 else {
                throw MMCliError.requiredParameter
            }
            if index > (last.count-1) || index < 0{
                throw MMCliError.outOfBounds
            }
            let file = last[index]
            var iterator = 0
            while iterator != keys.count{
                if keys[iterator] == "creator" || keys[iterator] == "runtime" || keys[iterator] == "resolution" || keys[iterator] == "runtime" || keys[iterator] == "date-created" || keys[iterator] == "date-modified"{
                    print("\(keys[iterator]) is a required metadata item for this file and cannot be removed")
                    iterator += 1
                    continue
                }
                if file.metadata.contains(where: {
                    if $0.keyword == keys[iterator]{
                        return true
                    }
                    return false
                }){
                    library.remove(key: keys[iterator], file: file)
                    print("Metadata with keyword '\(keys[iterator])' has been deleted from to \(file.filename)")
                    iterator += 1
                }
                else{
                    print("The metadata key ' \(keys[iterator]) ' you are trying to remove from the specified file does not exist. Please use the list command to see which files have which metadata attached to them.")
                    iterator += 1
                }
            }
        }
        else{
            throw MMCliError.wrongFormat
        }
    }
}

/// Command handler to deal with the SetCommand
class SetCommand: MMCommand{
    var results: MMResultSet? = nil
    var last: [MMFile]
    var library: Collection
    var metadata: [String]
    
    /// Creates a new Set Command with a file to change, metadata to change, and the collection to change
    init(metadata: [String], library: Collection, last: [MMFile]){
        self.last = last
        self.library = library
        self.metadata = metadata
    }
    
    ///
    /// Removes the metadata from the file if it exists, then adds the new metadata, printing the appropriate messages and checking for special cases.
    /// Throws:
    /// - There is no metadata to add
    /// - If there isn't the right number of paramaters
    /// - If there is no result set
    /// - If the index is out of bounds
    /// - If the arguments are in the wrong format
    func execute() throws{
        if last.isEmpty{
            throw MMCliError.missingResultSet
        }
        if metadata.isEmpty{
            throw MMCliError.invalidParameters
        }
        if let index = Int(metadata[0]){
            metadata.removeFirst()
            guard metadata.count > 0 else {
                throw MMCliError.requiredParameter
            }
            guard metadata.count%2 == 0 else{
                throw MMCliError.wrongFormat
            }
            if index > (last.count-1) || index < 0{
                throw MMCliError.outOfBounds
            }
            let file = last[index]
            var iterator = 0
            while iterator != metadata.count{
                let data = Metadata(keyword: metadata[iterator], value: metadata[iterator+1])
                let key = metadata[iterator]
                if key == "creator" || key == "runtime" || key == "resolution" || key == "runtime" || metadata[iterator] == "date-created" || metadata[iterator] == "date-modified"{
                    print("\(key) is a special metadata item and cannot be changed")
                    iterator += 2
                    continue
                }
                library.remove(key: key, file: file)
                library.add(metadata: data, file: file)
                print("Meta data updated for \(file.filename), \(metadata[iterator]) set to \(metadata[iterator+1])")
                iterator += 2
            }
        }
        else{
            throw MMCliError.wrongFormat
        }
    }
}

/// Handle unimplemented commands by throwing an exception when trying to execute this command.
class UnimplementedCommand: MMCommand{
    var results: MMResultSet? = nil
    
    ///
    /// Throws:
    /// - Always throws unimplemented command error
    func execute() throws{
        throw MMCliError.unimplementedCommand
    }
}

/// Command handler to deal with the SaveCommand
class SaveCommand: MMCommand{
    var results: MMResultSet? = nil
    
    var library : Collection
    var filename: [String]
    
    /// Intialises with the file name to save and the library to save
    init(params: [String], library: Collection){
        self.filename = params
        self.library = library
    }
    
    ///
    /// Creates a CollectionToJSON object and attempts to write the collection to the specified filename.
    ///
    func execute() throws {
        let pars = CollectionToJSON()
        try pars.write(filename: filename[0], items: library.library)
    }
}

/// Command handler to deal with the SaveSearchCommand
class SaveSearchCommand: MMCommand{
    var results: MMResultSet?
    var filePath : [String]
    
     /// Intialises with the file path to save and the result set to save.
    init(params: [String], results: MMResultSet){
        self.filePath = params
        self.results = results
    }
    
    ///
    /// Creates a CollectionToJSON object and attempts to write result set (if it exists) to the specified filename.
    ///
    func execute() throws {
        let pars = CollectionToJSON()
        let files = results?.getResults()
        if (files?.isEmpty)!{
            throw MMCliError.missingResultSet
        }
        try pars.write(filename: filePath[0], items: files!)
    }
}

/// Command handler to deal with the TestCommand
class TestCommand: MMCommand{
    var results: MMResultSet?
    
    ///
    /// Creates a test object which automatically runs our tests.
    ///
    func execute() throws {
        let testing = test()
        testing.functionalityTests()
        testing.errorFormatTests()
        testing.testPrintErrors()
    }
}

/// Class that handles the create command, this command lets the user create a new file manually
class CreateCommand:FileCreator, MMCommand{
    var results: MMResultSet?
    var library : Collection
    var filesToAdd:File?
    var file = [String:Any]()
    var metadataArray = [String:String]()
    var paramArray: [String]
    var type:String?

    /// Creates a new CreateComamnd with the given file type the user wants to create, and the user's media Collection to add the file to
    init(params: [String], library: Collection){
        self.library = library
        self.paramArray = params
    }
    
    ///
    /// This function creates a metadata dictionary that is used when creating a new file
    /// It asks the user for a KEY followed by a VALUE and adds this to the dictionary
    /// - returns:
    /// - A dictionary of user inputed metadata
    ///
    func getMetaData()->[String:String]{
        var metadataDicBuilder = [String:String]()
        
        print("Please enter the files metadata by KEY followed by space VALUE (repeated for as many metadata entries as needed, type quit to stop): ")
        var metaDataCommand = readLine()
        while(metaDataCommand != "quit"){
            let metaData = metaDataCommand?.components(separatedBy: " ")
            if metaData?.count==2{
                metadataDicBuilder[metaData![0]] = metaData![1]
                print("Please enter metadata by KEY followed by space VALUE (or quit)")
             }else{
                print("Please enter ONE KEY followed by ONE VALUE")
            }
            metaDataCommand = readLine()
        }
        return metadataDicBuilder
    }
    ///
    /// This function executes the create command a metadata dictionary that is used when creating a new file
    /// It asks the user for a KEY *space* followed by a VALUE and adds this to the dictionary
    ///
    func execute() throws {
        if paramArray.isEmpty{
            throw MMCliError.requiredParameter
        }
        self.type = paramArray[0].lowercased()
        if (type == "image" || type == "video" ||  type == "audio" ||  type == "document")  {
            
        
        print("Please enter a valid file path: ")
        let path = readLine()
        print("Please enter a creator for the file: ")
        let creator = readLine()
        switch(type){
        case "video":
            print("Please enter the runtime for this video file: ")
            let runtime = readLine()
            print("Please enter the resoultion of this video file: ")
            let resoultion = readLine()
            metadataArray = getMetaData()
            metadataArray["resolution"] = resoultion
            metadataArray["runtime"] = runtime
            break
        case "audio":
            print("Please enter the runtime for this image file: ")
            let runtime = readLine()
            metadataArray = getMetaData()
            metadataArray["runtime"] = runtime
            break
        case "image":
            print("Please enter the resoultion for this image file: ")
            let resoultion = readLine()
            metadataArray = getMetaData()
            metadataArray["creator"] = creator
            metadataArray["resolution"] = resoultion
            break
        case "document":
            metadataArray = getMetaData()
            metadataArray = getMetaData()
            break
        default:
            throw MMCliError.invalidListType
        }
        metadataArray["creator"] = creator
        file["type"] = type
        file["fullpath"] = path
        file["metadata"] = metadataArray
        if let newFile = try checkAndLoad(file: file, at: 0){
            library.add(file: newFile)
        }
        }else{
            throw MMCliError.invalidListType
        }
    }
}

/// Handle the help command.
class HelpCommand: MMCommand{
   
    var results: MMResultSet? = nil
    func execute() throws{
        print("""
\thelp                              - this text
\tload <filename> ...               - load file into the collection
\tlist <term> ...                   - list all the files that have the term specified
\tlist                              - list all the files in the collection
\tadd <number> <key> <value> ...    - add some metadata to a file
\tset <number> <key> <value> ...    - this is really a del followed by an add
\tdel <number> <key> ...            - removes a metadata item from a file
\tsave-search <filename>            - saves the last list results to a file
\tsave <filename>                   - saves the whole collection to a file
\tquit                              - exit the program (without prompts)
\tcreate <file type>                - manualy create a new file
\tlist-type <file type>             - lists all the files of the specified type
\thelp                              - this text
""")
        // for example:
        
        // load foo.json bar.json
        //      from the current directory load both foo.json and bar.json and
        //      merge the results
        
        // list foo bar baz
        //      results in a set of files with metadata containing foo OR bar OR baz
        
        // add 3 foo bar
        //      using the results of the previous list, add foo=bar to the file
        //      at index 3 in the list
        
        // add 3 foo bar baz qux
        //      using the results of the previous list, add foo=bar and baz=qux
        //      to the file at index 3 in the list
    }
}

/// Handle the confirm command. Exits the program (with exit code 0) without
/// checking if there is anything to save.
class QuitCommand : MMCommand{
    var results: MMResultSet? = nil
    func execute() throws{
        exit(0)
    }
}
/// Handle the Quit command, prints a warning message and new quit instructions
class QuitCheckCommand : MMCommand{
    var results: MMResultSet? = nil
    func execute() throws{
        print("If you quit any unsaved changed WILL be lost! If you are sure you wish to quit, please type confirm, otherwise use the save or save-search command to save before you quit")
    }
}

