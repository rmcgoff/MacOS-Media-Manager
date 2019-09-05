//
//  test.swift
//  MediaLibraryManager
//
//  Created by Jeremiah Kumar on 8/29/18.
//  Copyright © 2018 Paul Crane. All rights reserved.
//

import Foundation

class test{
    var last = MMResultSet()
    var lastExport = MMResultSet()
    var collection = Collection()
    var collectionExport = Collection()
    var loadHandler : LoadCommand?
    var listHandler: ListCommand?
    var saveHandler: SaveSearchCommand?
    var setHandler: SetCommand?
    var addHandler: AddCommand?
    var delHandler: DeleteCommand?
    var listTypeHandler: ListTypeCommand?
    ///Change the importFilePath
    var importFilePath = ["~/346/asgn1/assignment-one-media-manager-library-cranes-bennanis/MediaLibraryManager/test.json"]
    var exportedFilePath = ["~/Desktop/jsonout.json"]
    
    init() {
        
    }
    
    /// This function tests functionality tests for add,set,delete, load, list and save commands
    func functionalityTests(){
        
        loadHandler = LoadCommand(params: importFilePath, library: collection)
        let searchTermArray = ["resolution"]
        listHandler = ListCommand(searchTerm: searchTermArray, library: collection)
        let testLoadResult = testLoad()
        let testListResult = testList()
        saveHandler = SaveSearchCommand(params: exportedFilePath, results: last)
        let testSaveResult = testSave()
        
        print("---------FUNCTIONALITY TESTING---------\n")
        if testLoadResult{
            print("=========Load Test Successful=========")
        }
        else{
            print("!!!!!!!!Load Test Failed!!!!!!!!")
            
        }
        if testListResult{
            print("=========List Test Successful=========")
        }
        else{
            print("!!!!!!!!Save Test Failed!!!!!!!!")
        }
        if testSaveResult{
            print("=========Save Test Successful=========\n")
        }
        else{
            print("!!!!!!!!Save Test Failed!!!!!!!!\n")
        }
        
        print("...testing add for MMResultSet: \n")
        last.showResults()
        print("\n..adding to new meta data to file at index 0")
        var newMetaData = ["0","Location","Paris"]
        addHandler = AddCommand(metadata: newMetaData, library: collection, last: last.getResults())
        let testAddResult = testAdd()
        
        if testAddResult{
            print("=========Add Test Successful=========\n")
        }
        else{
            
            print("!!!!!!!!Add Test Failed!!!!!!!!\n")
        }
        print("\n...testing set for MMResultSet: \n")
        newMetaData = ["0","Location","New Zealand"]
        last.showResults()
        print("\n..setting to new meta data to file at index 0")
        setHandler = SetCommand(metadata: newMetaData, library: collection, last: last.getResults())
        let testSetResult = testSet()
        if testSetResult{
            print("=========Set Test Successful=========\n")
        }
        else{
            print("!!!!!!!!Set Test Failed!!!!!!!!\n")
        }
        print("\n...testing delete for MMResultSet: \n")
        last.showResults()
        print("\n..deleting key for file at index 0")
        let toDelete = ["0","Location"]
        delHandler = DeleteCommand(keys: toDelete, library: collection, last: last.getResults())
        let testDeleteResult = testDelete()
        if testDeleteResult{
            print("=========Delete Test Successful=========\n")
        }
        else{
            print("!!!!!!!!Delete Test Failed!!!!!!!!\n")
        }
        
    }
    
    
    /// This error tests functionality tests for add,set,delete, load, list and save commands
    func errorFormatTests(){
        print("---------ERROR/FORMAT TESTING---------\n")
        let noIndex = ["Location","New Zealand"]
        let noValue = ["0","Location"]
        let outOfBounds = ["5","Location","New Zealand"]
        let emptyResultSet = MMResultSet()
        let stringNotInt = ["ddd","ddd","ddd"]
        addHandler = AddCommand(metadata: outOfBounds, library: collection, last: last.getResults())
        
        ///FOR ADD ERROR TESTING
        if testAddErrors() == "outOfBounds"{
            print("=========out of bounds test for add successful=========")
        }
        else{
            print("!!!!!!!!out of bounds test for add failed!!!!!!!!")
        }
        addHandler = AddCommand(metadata: noIndex, library: collection, last: last.getResults())
        if testAddErrors() == "wrongFormat"{
            print("=========no index test for add successful=========")
        }
        else{
            print("!!!!!!!!no index test for add failed!!!!!!!!")
        }
        addHandler = AddCommand(metadata: noValue, library: collection, last: last.getResults())
        if testAddErrors() == "wrongFormat"{
            print("=========missing key/value test for add successful=========")
        }
        else{
            print("!!!!!!!!missing key/value test for add failed!!!!!!!!")
        }
        addHandler = AddCommand(metadata: stringNotInt, library: collection, last: last.getResults())
        if testAddErrors() == "wrongFormat"{
            print("=========string instead of list index value test for add successful=========")
        }
        else{
            print("!!!!!!!!string instead of list index value test for add failed!!!!!!!!")
        }
        
        addHandler = AddCommand(metadata: noValue, library: collection, last: emptyResultSet.getResults())
        if testAddErrors() == "missingResultSet"{
            print("=========missing result-set test for add successful=========")
        }
        else{
            print("!!!!!!!!missing result-set test for add failed!!!!!!!!")
        }
        
        ///FOR SET ERROR TESTING
        setHandler = SetCommand(metadata: outOfBounds, library: collection, last: last.getResults())
        if testSetErrors() == "outOfBounds"{
            print("=========out of bounds test for set successful=========")
        }
        else{
            print("!!!!!!!!out of bounds test for set failed!!!!!!!!")
        }
        setHandler = SetCommand(metadata: noIndex, library: collection, last: last.getResults())
        if testSetErrors() == "wrongFormat"{
            print("=========no index test for set successful=========")
        }
        else{
            print("!!!!!!!!no index test for set failed!!!!!!!!")
        }
        setHandler = SetCommand(metadata: stringNotInt, library: collection, last: last.getResults())
        if testSetErrors() == "wrongFormat"{
            print("=========string instead of list index value test for set successful=========")
        }
        else{
            print("!!!!!!!!string instead of list index value test for set failed!!!!!!!!")
        }
        setHandler = SetCommand(metadata: noValue, library: collection, last: last.getResults())
        if testSetErrors() == "wrongFormat"{
            print("=========missing key/value test for set successful=========")
        }
        else{
            print("!!!!!!!!missing key/value test for set failed!!!!!!!!")
        }
        
        setHandler = SetCommand(metadata: noValue, library: collection, last: emptyResultSet.getResults())
        if testSetErrors() == "missingResultSet"{
            print("=========missing result-set test for set successful=========")
        }
        else{
            print("!!!!!!!!missing result-set test for set failed!!!!!!!!")
        }
        
        ///FOR DELETE ERROR TESTING
        delHandler = DeleteCommand(keys: outOfBounds, library: collection, last: last.getResults())
        if testDelErrors() == "outOfBounds"{
            print("=========out of bounds test for delete successful=========")
        }
        else{
            print("!!!!!!!!out of bounds test for delete failed!!!!!!!!")
        }
        delHandler = DeleteCommand(keys: noIndex, library: collection, last: last.getResults())
        if testDelErrors() == "wrongFormat"{
            print("=========no index test for delete successful=========")
        }
        else{
            print("!!!!!!!!no index test for delete failed!!!!!!!!")
        }
        delHandler = DeleteCommand(keys: stringNotInt, library: collection, last: last.getResults())
        if testDelErrors() == "wrongFormat"{
            print("=========string instead of list index value test for delete successful=========")
        }
        else{
            print("!!!!!!!!string instead of list index value test for delete failed!!!!!!!!")
        }
        
        delHandler = DeleteCommand(keys: noValue, library: collection, last: emptyResultSet.getResults())
        if testDelErrors() == "missingResultSet"{
            print("=========missing result-set test for delete successful=========")
        }
        else{
            print("!!!!!!!!missing result-set test for delete failed!!!!!!!!")
        }
        
        loadHandler = LoadCommand(params: ["not a path1"], library: collection)
        if testLoadErrors(){
             print("=========invalid path test for Load successful=========")
        }
        else{
             print("!!!!!!!!invalid path test for Load failed!!!!!!!!")
        }
        
        saveHandler = SaveSearchCommand(params: exportedFilePath, results: emptyResultSet)
        if testSaveErrors(){
            print("=========missing result-set test for Save successful=========")
        }
        else{
            print("!!!!!!!!missing result-set test for Save failed!!!!!!!!")
        }
        
        if testTypeSearch(){
            print("=========invalid search type test for list-term successful=========")
        }
        else{
            print("!!!!!!!!invalid search type test for list-term failed!!!!!!!!")
        }
        
        
    }

    
    
    //tests print statments that we couldn't implement as throws due to us wanting our code to continue parsing data even after an error had been caught
    func testPrintErrors(){
        print("\n---------PRINT ERROR MESSAGES---------\n")
        let searchTermArray = ["notAMetadataKey"]
        let deleteArray = ["0","notARealKey"]
        let deleteCreator = ["0","creator"]
        listHandler = ListCommand(searchTerm: searchTermArray, library: collection)
        delHandler = DeleteCommand(keys: deleteArray, library: collection, last: last.getResults())
        
        do{
            print("\n------testing error message for attempting to search for a key that doesn't exist-----")
            try listHandler?.execute()
        }catch{
            
        }
        do{
            print("\n------testing error message for attempting to delete a key that doesn't exist------")
            try delHandler?.execute()
        }catch{
            
        }
        do{
            delHandler = DeleteCommand(keys: deleteCreator, library: collection, last: last.getResults())
            print("\n------testing error message for attempting to delete the required key creator------")
            try delHandler?.execute()
        }catch{
        }
        
        do{
            listTypeHandler = ListTypeCommand(searchType: ["audio"], library: collection)
            print("\n------testing list-type for audio files------")
            try listTypeHandler?.execute()
            listTypeHandler?.results?.showResults()
        }catch{
            
        }
        
    }

    
    /// This function tests the invalid search type when using list-term.
    /// - Returns:
    /// a string representing the error code
    ///
    func testTypeSearch()->Bool{
        do{
            listTypeHandler = ListTypeCommand(searchType: ["auddio"], library: collection)
                try listTypeHandler?.execute()
            
        }catch MMCliError.invalidListType {
            return true
        }
        catch{
            return false
        }
        return false
    }
    
    

    /// This function tests the various error messages that the add command throws.
    /// It then executes the Add command using various invalid paramaters.
    /// - Returns:
    /// a string representing the error code
    ///
    func testAddErrors()->String{
        do{
            try addHandler?.execute()
            
        }catch MMCliError.missingResultSet {
            return "missingResultSet"
        }
        catch MMCliError.requiredParameter{
            return "requiredParameter"
        }
        catch MMCliError.wrongFormat{
            return "wrongFormat"
        }
        catch MMCliError.outOfBounds{
            return "outOfBounds"
        }
        catch{
            return "error"
        }
        return "error"
    }
    
    /// This function tests the various error messages that the delete command throws.
    /// It then executes the Delete command using various invalid paramaters.
    /// - Returns:
    /// a string representing the error code
    ///
    func testDelErrors()->String{
        do{
            try delHandler?.execute()
            
        }catch MMCliError.missingResultSet {
            return "missingResultSet"
        }
        catch MMCliError.requiredParameter{
            return "requiredParameter"
        }
        catch MMCliError.wrongFormat{
            return "wrongFormat"
        }
        catch MMCliError.outOfBounds{
            return "outOfBounds"
        }
        catch{
            return "error"
        }
        return "error"
    }
    
    /// This function tests the various error messages that the Set command throws.
    /// It then executes the Set command using various invalid paramaters.
    /// - Returns:
    /// a string representing the error code
    ///
    func testSetErrors()->String{
        do{
            try setHandler?.execute()
            
        }catch MMCliError.missingResultSet {
            return "missingResultSet"
        }
        catch MMCliError.requiredParameter{
            return "requiredParameter"
        }
        catch MMCliError.wrongFormat{
            return "wrongFormat"
        }
        catch MMCliError.outOfBounds{
            return "outOfBounds"
        }
        catch{
            return "error"
        }
        return "error"
    }
    
    
    /// This function tests the error message that the Load command throws.
    /// It then executes the Load command with an invalid path.
    /// - Returns:
    /// a boolean true value if the error was catched
    ///
    func testLoadErrors()->Bool{
        do{
            try loadHandler?.execute()
            
        }catch MMCliError.unableToLoad{
            return true
        }
        catch{
            return false
        }
        return false
    }
    
    /// This function the error message for the Save-Search command.
    /// It then executes the Save command with a empty result set.
    /// - Returns:
    /// a boolean true value if the error was catched
    ///
    func testSaveErrors()->Bool{
        do{
            try saveHandler?.execute()
            
        }catch MMCliError.missingResultSet{
            return true
        }
        catch{
            return false
        }
        return false
    }
    
    ////FUNCTIONALITY TEST FUNCTIONS
    
    /// This function tests the delete command to make sure the command worked as intended.
    /// The function searches the collection to make sure the file has been deleted after the delete command has been executed
    /// If the search result returns a capacity of 1 for the term location, that means that the metadata has not been deleted.
    /// - Returns:
    /// a boolean true value if location metdata has been deleted
    ///
    func testDelete()->Bool{
        do{
            var searchResult: [MMFile]
            try delHandler?.execute()
            
            print("Seraching file to make sure the metadata has been deleted")
            searchResult = collection.search(term: "location")
            if searchResult.capacity == 1{
                print(searchResult[0].filename)
                //makes sure only one file has had the new meta data added to it
                print("error, meta Data has not been deleted")
                return false
            }
            else{
                print("Meta Data has been deleted")
                return true
            }
        }catch{
            return false
        }
    }
    ///
    /// This function tests the set command to make sure the command has worked as intended.
    /// The function searches the collection to make sure the file has been set with the new term.
    /// If the search result returns a capacity of 1 more than one metdata has been set with this term.
    /// - Returns:
    /// a boolean true value if metdata has been set
    ///
    func testSet()->Bool{
        do{
            var searchResult: [MMFile]
            try setHandler?.execute()
            
            print("Seraching file to make sure the new metadata has been set")
            searchResult = collection.search(term: "new zealand")
            guard searchResult.capacity == 1 else{
                //makes sure only one file has had the new meta data added to it
                print("error, more than one file has this metadata")
                return false
            }
            if searchResult[0].filename == "monaLisa.jpg"{
                print("file has the newly set meta data")
                return true
            }
            
        }catch{
            return false
        }
     return false
    }
    
    ///
    /// This function tests the add command to make sure the command has worked as intended.
    /// The function searches the collection to make sure the new metdata has been added
    /// If the search result returns a capacity of 1 more than one metdata has been set with this term.
    /// - Returns:
    /// a boolean true value if metdata has been added
    ///
    func testAdd()->Bool{
        do{
            var searchResult: [MMFile]
            try addHandler?.execute()
            print("Seraching file to make sure the new metadata has been added")
            searchResult = collection.search(term: "location")
            guard searchResult.capacity == 1 else{
                //makes sure only one file has had the new meta data added to it
                print("error, more than one file has this metadata")
                return false
            }
            if searchResult[0].filename == "monaLisa.jpg"{
                print("file has the newly added meta data")
                return true
            }
            else{
                print("file does not have the newly added meta data")
                return false
            }
        }
        catch{
            return false
        }
    }
    
    ///
    /// This function tests the list command to make sure the command has worked as intended.
    /// The function compares the results of using the list command against a expected output.
    /// - Returns:
    /// a boolean true value if list has a match with expected results
    ///
    func testList()->Bool{
        do{
        
        try listHandler?.execute()
        if let results = listHandler?.results{
            //results.showResults()
            last = results;
        }
            for (index,file) in last.getResults().enumerated(){
                if file.filename != TestData.expectedSearchTerm[index]{
                    return false
                }
            }
        return true
        
        }catch{
            return false
        }
    }
    
    ///
    /// This function tests the save-search command to make sure the command has worked as intended.
    /// The function exports/saves the data in a MMResult into a file, then loads the exported file into a second collection
    /// If the data in the second collection matches the MMResult, then the test was successful.
    /// - Returns:
    /// a boolean true value if the MMResult matches the exported data
    ///
    func testSave()->Bool{
        do{
            try saveHandler?.execute()
            loadHandler = LoadCommand(params: exportedFilePath, library: collectionExport)
            try loadHandler?.execute()
            listHandler = ListCommand(searchTerm: [], library: collectionExport)
            try listHandler?.execute()
            
            let lastExport = listHandler?.results
            lastExport?.showResults()
            
            for (index,file) in last.getResults().enumerated(){
                if file.filename != lastExport?.getResults()[index].filename{
                    return false
                }
            }
        }catch{
            return false
        }
        return true
    }
    
    ///
    /// This function tests the load command to make sure the command has worked as intended.
    /// The function compares the results of collection's dictionary after the load command has executed against an expected output.
    /// - Returns:
    /// a boolean true value if the collection's dictionary has a match with the expected results
    ///
    func testLoad() ->Bool{
        do{
            try loadHandler?.execute()

            let collectionDic = collection.dictionary
            for term in collectionDic{

                let files = term.value
                //checks to see if expected key key exists
                if TestData.expectedDic[term.key] == nil && term.key != "date-created"{
                    print(term.key + " not in there")
                    return false
                }
                for file in files{
                    //checks to see if expected value exists
                    if TestData.expectedDic[term.key]?.contains(file.description)==false{
                        return false
                    }
                }
            }
            return true
            
        }catch {
            return false
        }
    }
}
