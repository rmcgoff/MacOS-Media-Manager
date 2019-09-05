//
//  ViewController.swift
//  Assignment2
//
//  Created by Ryan McGoff on 9/19/18.
//  Copyright © 2018 Ryan McGoff. All rights reserved.
//

import Cocoa
import AppKit
import AVFoundation

class Bookmark: NSObject{
    @objc dynamic var bookmarkString: String
    init(string: String){
        self.bookmarkString = string
    }
}

extension NSView {
    var backgroundColor: NSColor? {
        get {
            if let colorRef = self.layer?.backgroundColor {
                return NSColor(cgColor: colorRef)
            } else {
                return nil
            }
        }
        set {
            self.wantsLayer = true
            self.layer?.backgroundColor = newValue?.cgColor
        }
    }
}

extension Notification.Name {
    static let doubleClick = Notification.Name("doubleClick")
    static let windowThatClosed = Notification.Name("windowThatClosed")
    static let dropItem = Notification.Name("dropItem")
    static let reloadLibrary = Notification.Name("reloadLibrary")
    static let reloadPanelWithNewFile = Notification.Name("reloadPanelWithNewFile")
    static let save = Notification.Name("save")
    static let load = Notification.Name("load")
    static let addBookmark = Notification.Name("addBookmark")
}


//View Controller class that holds the outlets for the main ApplicationView
class ViewController: NSViewController, NSCollectionViewDelegate, NSTextFieldDelegate{
    static var currentlySelectedFile: File? = nil
    static var bookmarks = ["All", "Image", "Audio", "Document", "Video"]

    var selecteditemIndexPath: Set<IndexPath>? = nil
    var mutableSelection = 0 //how much of the mutable array we should allow users to access
    var addWindow: AddWindowController? = nil;
    var contentWindow: ContentWindow? = nil;
    var addBookmarkWindow: AddBookmarkWindow? = nil;
    var data: dataSource!
    var library = Collection() //The library with all files in it
    var searchTermLibrary = Collection() //The library with just the searchTerm files in it
    var previousResults = [String]() //All the files already loaded in
    var currentlySelectedBookmark = "All" //The filter button currently selected, default is all
    var currentlyOpenWindows = [String]()


    @IBOutlet weak var addToBookmarksButton: NSButton!
    @IBOutlet weak var outletPopUp: NSPopUpButton!
    @IBOutlet weak var outletMetadataTable: NSTableView!
    @IBOutlet var metadataArrayController: NSArrayController!
    @IBOutlet weak var leftNavView: NSView!
    @IBOutlet weak var collection: NSCollectionView!
    @IBOutlet weak var outletSearchField: NSSearchField!
    @IBOutlet weak var noteView: NSView!
    @IBOutlet weak var noteTitle: NSTextField!
    @IBOutlet weak var noteBody: NSTextField!
    @IBOutlet weak var addMetadataButtonsView: NSView!
    @IBOutlet weak var minusMetadataButton: NSButton!
    @IBOutlet weak var addMetadataButton: NSButton!
    @IBOutlet weak var valueColumn: NSTableColumn!
    @IBOutlet weak var outletSaveButton: NSButton!
    @IBOutlet weak var addBookmarkButton: NSButton!
    @IBOutlet var bookmarkController: NSArrayController!
    @IBOutlet weak var bookmarkTable: NSTableView!
    
    @objc dynamic var bookmarkArray = NSMutableArray()
    @objc dynamic var selectedItemMetadata = NSMutableArray()
    
    var bookmarkTableDelegate = BookmarkTableDelegate()
    var metadataTableDelegate : MetadataTableDelegate? = nil
    
    //This method uses the NSSavePanel class to let the user select an exisiting json file path to write to or
    // lets the user create a new file path. We pass the given file name to our SaveCommand for processing
    func save(){
        let mySave = NSSavePanel()
        mySave.allowedFileTypes = ["json"]
        mySave.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                let exportFilePath = [mySave.url?.relativePath]
                do {
                    let save = SaveCommand(params: exportFilePath as! [String], library: self.library)
                    try save.execute()
                } catch {
                    print("Save did not work please try again")
                }
            } else {
                return
            }
        }
    }
    
    /// This function is called when the user hits a save button and it just calls the save function.
    /// - Parameters:
    /// - sender: the save button
    @IBAction func clickedSaveButton(_ sender: NSButton) {
        save()
    }
    
    /// This method filters the collection based on what the user types in the search bar. First it checks if the searchBar.
    /// is empty, and if so, it reloads the entire library using the applyFilter method with "All" and returns.
    /// If there is a search term, we search the library for it and assign those results to the searchTermLibrary.
    /// This is now the library of files we want to view, so we set the dataSources library to  bethis and reload
    /// the data after reapplying the currently Selected filter option.
    /// - Parameters:
    /// - sender: the search bar
    @IBAction func searched(_ sender: Any) {
        let searchTerm = outletSearchField.stringValue;
        if (searchTerm.isEmpty){
            applyFliter(sender: "All")
            metadataArrayController.remove(contentsOf: selectedItemMetadata as! [Any])
            return
        }
        let filteredLibrary = library.search(term:searchTerm)
        data.collection.library = filteredLibrary
        searchTermLibrary.library = filteredLibrary
        data.collectionNo = filteredLibrary.count
        applyFliter(sender: currentlySelectedBookmark)
        metadataArrayController.remove(contentsOf: selectedItemMetadata as! [Any])
        collection!.reloadData()
    }

    /// This method handles the loading action by loading a selected (manditorily JSON) file.
    /// If the user selects a file, this method gets the path of the file, resets any currently loaded data in the data source to
    /// it's original, full library (using the apply filter with all selected). This is because due to potentially
    /// selected filters, the library may not be full at the moment. It then loads in the new data using the data sources loadData method.
    /// This new library and becomes the new view controller library, and then the currently selected user filter is re applied before the
    /// data is reloaded.
    func load(){
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["json"];
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            do{
                let resultString = try String(contentsOf: result!)
                if (previousResults.contains(resultString)){
                    print("file is already in the collection")
                    return
                }
                previousResults.append(resultString)
            } catch{
                print("Please make sure the file is in the correct format")
            }
            if (result != nil) {
                let path = result!.path
                applyFliter(sender: "All")
                data.loadData(path: [path])
                library = data.collection.copy() as! Collection
                applyFliter(sender: currentlySelectedBookmark)
                collection!.reloadData()
                outletSaveButton.isEnabled = true
                let indexSet = NSIndexSet(index: 0)
                bookmarkTable.selectRowIndexes(indexSet as IndexSet, byExtendingSelection: false)
            }
        } else {
            return
        }
    }
    
    /// This method is called when the user hits the laod button and just calls the load function.
    /// - Parameters:
    /// - sender: the load button
    @IBAction func clickedLoadButton(_ sender: NSButton) {
        load()
    }
    
    
    ///  This method creates a new AddWindow with appropriate variables when the add metadata button is clicked.
    /// - Parameters:
    /// - sender: The add button
    @IBAction func addMetadataButtonClicked(_ sender: NSButton) {
                addMetadataButton.isEnabled = false
                addWindow = AddWindowController(library: library, button: addMetadataButton);
                addWindow?.showWindow(nil)
    }
    
    /// This method removes a metadata item from the currently selected file and then reloads the library so that this data
    /// change is visually shown. It also updates the dictionary.
    /// - Parameters:
    /// - sender: The minus button
    @IBAction func minusMetadataButtonClicked(_ sender: Any) {
                let selectedRow = outletMetadataTable.selectedRow
                library.dictRemover(key: (ViewController.currentlySelectedFile?.metadata[selectedRow].keyword)!,
                                    value: (ViewController.currentlySelectedFile?.metadata[selectedRow].value)!,
                                    file : ViewController.currentlySelectedFile!)
                ViewController.currentlySelectedFile?.metadata.remove(at: selectedRow)
                reloadLibrary()
    }
    
    ///  This method creates a new AddBookMarkWindow with appropriate variables when the add bookmark button is clicked.
    func addBookmark(){
        addBookmarkButton.isEnabled = false
        addBookmarkWindow = AddBookmarkWindow(outletPopUp: outletPopUp, bookmarkController: bookmarkController, AddBookmarkButton: addBookmarkButton);
        addBookmarkWindow?.showWindow(nil)
    }
    
    ///  This method is called when users click the add bookmark button and calls the addbookmark function.
    /// - Parameters:
    /// - sender: The add button
    @IBAction func addBookMark(_ sender: Any) {
        addBookmark()
    }
    
    
    ///  This method adds the current bookmark to a file
    /// - Parameters:
    /// - sender: The add file to bookmark button
    @IBAction func addFileToBookmark(_ sender: Any) {
        let bookmark = outletPopUp.selectedItem?.title
        ViewController.currentlySelectedFile!.bookmarks.append(bookmark!)
    }
    
    ///  This method is called when a filter is selected.
    /// It finds the currently selected bookmark string and uses the apply filter method to reload the library with that string
    /// as a filter.
    /// - Parameters:
    /// - sender: The bookmark table
    @IBAction func bookmarkSelected(_ sender: NSTableView) {
        let selectionIndex = collection!.selectionIndexPaths
        collection.delegate?.collectionView!(collection, didDeselectItemsAt: selectionIndex)
        let selectedBookmark = bookmarkArray[bookmarkTable.selectedRow] as! Bookmark
        let currentBookmarkString = selectedBookmark.bookmarkString
        currentlySelectedBookmark = currentBookmarkString
        applyFliter(sender: currentBookmarkString)
    }
    
    ///  This method uses a library's search method to generate a new set of files. This set becomes the data sources new library
    /// to work with, and the count is appropriately updated and the data reloaded. If the search field is currently empty, we use
    /// the full library and if there is a search term, we use the library of just those requested files as represented by the
    /// searchTermLibrary variable.
    /// - Parameters:
    /// - sender: The string representation of which filter is requested.
    func applyFliter(sender: String){
        if (outletSearchField.stringValue.isEmpty){
            let filteredLibrary = library.search(type:sender)
            data.collection.library = filteredLibrary
            data.collectionNo = filteredLibrary.count
            collection!.reloadData()
        }
        else{
            let tempLibrary = searchTermLibrary.search(type:sender)
            data.collection.library = tempLibrary
            data.collectionNo = tempLibrary.count
            collection!.reloadData()
        }
    }
    
    /// This method reloads the collection in order to reflect any data changes.
    /// First it empties the metedata array, then it reloads the data (which will update any data changes) and then
    /// It calls the collectionViewDelegates "didSelectItemsAt" method. The delegate is the view controller and this method is further below.
    func reloadLibrary(){
        let selectionIndex = collection!.selectionIndexPaths
        if selectionIndex.isEmpty{
            applyFliter(sender: "All")
            let indexSet = NSIndexSet(index: 0) as IndexSet
            bookmarkTable.selectRowIndexes(indexSet, byExtendingSelection: false)
            return
        }
        metadataArrayController.remove(contentsOf: selectedItemMetadata as! [Any])
        collection!.reloadData()
        collection!.selectItems(at: selectionIndex, scrollPosition: .top)
        collection!.delegate?.collectionView!(collection!, didSelectItemsAt: selectionIndex)
    }
    
    /// This method is called when the view apears and sets the background colors of the appropriate views.
    override func viewWillAppear() {
        addMetadataButtonsView.backgroundColor = NSColor.white
        noteView.backgroundColor = NSColor.white
    }
    
    /// This method is called when the view loads. It sets the delegates and datasources for all of the items that require it,
    /// as well as setting the intial enabled state of the appropriate buttons. It also adds NotificationCenter obeservers so it
    /// can be informed of various events.
    override func viewDidLoad() {
        super.viewDidLoad()
        collection.delegate = (self as NSCollectionViewDelegate)
        data = dataSource()
        collection.dataSource = data
        collection.minItemSize = (NSSize(width: 200, height: 200))
        for _ in data.collection.library{
            let item = NSNib(nibNamed: NSNib.Name(rawValue: "CollectionViewItem"), bundle: nil)
            collection.register(item, forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CollectionViewItem"))
        }
        minusMetadataButton!.isEnabled = false
        addMetadataButton!.isEnabled = false
        noteBody.isHidden = true
        noteTitle.isHidden = true
        metadataTableDelegate = MetadataTableDelegate(minusButton: minusMetadataButton, mutableSelection: mutableSelection)
        outletMetadataTable.delegate = metadataTableDelegate
        noteBody.delegate = self
        outletSaveButton.isEnabled = false
        bookmarkController.add(contentsOf: [Bookmark(string: "All"),Bookmark(string: "Image"),Bookmark(string: "Document"),Bookmark(string: "Audio"),Bookmark(string: "Video")])
        bookmarkTable.deselectAll(nil)
        outletPopUp.isHidden = true
        addToBookmarksButton.isHidden = true
        outletPopUp.removeAllItems()
        bookmarkTable.delegate = bookmarkTableDelegate
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDoubleClickReceived(_:)), name: .doubleClick, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onWindowClosed(_:)), name: .windowThatClosed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onDropItem(_:)), name: .dropItem, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onReloadLibrary(_:)), name: .reloadLibrary, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadPanelWithNewFile(_:)), name: .reloadPanelWithNewFile, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSave(_:)), name: .save, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(onLoad(_:)), name: .load, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onAddBookmark(_:)), name: .addBookmark, object: nil)
    }
    
    
    ///  This method updates the static currently selected file field with a new file.
    /// After doing so it also updates the noteBody variable, and then populates the metadata array.
    /// It gets the "extra metadata" which is stored in variables, not the metadata array including the date created and modified
    /// fields. It adds the files normal metadata first and updates the mutable selection variable to be this count. These are the
    /// only data pieces allowed to be mutated. The rest of the metadata is added afterwards.
    /// - Parameters:
    /// - newFile: The new file to update with.
    func updateMetadataTable(newFile: File){
        metadataArrayController.remove(contentsOf: metadataArrayController.content as! [Any])
        ViewController.currentlySelectedFile = newFile
        
        var extraMetadata = [Metadata]()
        extraMetadata.append(Metadata(keyword: "creator", value: newFile.creator))
        if let audio = newFile as? Audio {
            extraMetadata.append(Metadata(keyword: "runtime", value: audio.runtime))
        }
        if let image = newFile as? Image {
            extraMetadata.append(Metadata(keyword: "resolution", value: image.resolution))
        }
        if let video = newFile as? Video {
            extraMetadata.append(Metadata(keyword: "resolution", value: video.resolution))
            extraMetadata.append(Metadata(keyword: "runtime", value: video.runtime))
        }
        
        var metadataCopy = newFile.metadata
        var dateModifiedObject : [MMMetadata]? = nil
        var dateCreatedObject : [MMMetadata]? = nil
        if let dateCreatedIndex = metadataCopy.index(where: { (item) -> Bool in
            item.keyword == "date-added"
        }){
            dateCreatedObject = [metadataCopy[dateCreatedIndex]]
            metadataCopy.remove(at: dateCreatedIndex)
        }
        if let dateModifiedIndex = metadataCopy.index(where: { (item) -> Bool in
            item.keyword == "date-modified"
        }){
            dateModifiedObject = [metadataCopy[dateModifiedIndex]]
            metadataCopy.remove(at: dateModifiedIndex)
        }
        metadataArrayController.add(contentsOf: metadataCopy)
        if dateCreatedObject != nil{
            metadataArrayController.add(contentsOf: dateCreatedObject! as [Any])
        }
        if dateModifiedObject != nil{
            metadataArrayController.add(contentsOf: dateModifiedObject! as [Any])
        }
        if metadataTableDelegate != nil{
            metadataTableDelegate?.mutableSelection = metadataCopy.count
        }
        metadataArrayController.add(contentsOf: extraMetadata)
        noteBody.stringValue = newFile.notes
    }
    
    /// When the notification is sent from the menu that a user wants to save, this method is called and invokes the save function.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onSave(_ notification:Notification){
        save()
    }
    
    /// When the notification is sent from the menu that a user wants to load, this method is called and invokes the load function.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onLoad(_ notification:Notification){
        load()
    }
    /// When the notification is sent from the menu that a user wants to add a bookmark, this method is called and invokes the appropriate function.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onAddBookmark(_ notification:Notification){
        addBookmark()
    }
    
    
    /// When the notification is sent from the content window that a next or previous button has been clicked, This method is called.
    /// It uses basic index bounds checks to calculate the next file index in the collection (looping), and then sets the static
    /// ViewController.currentlySelectedFile variable.  It then calls the update Metadata Function to properly change the metadata
    /// table and also informs the content window of the new files nors and metadata
    /// - Parameters:
    /// - notification: The notification sent
    @objc func reloadPanelWithNewFile(_ notification:Notification){
        let indexOfCurrentFile = data.collection.library.index(where: { (item) -> Bool in
            item.path == ViewController.currentlySelectedFile?.path
        })
        let libraryCount = data.collection.library.count
        var nextIndex: Int
        let type = notification.userInfo!["type"] as! String
        if type == "next"{
            if indexOfCurrentFile! == (libraryCount - 1){
                nextIndex = 0
            }
            else{
                nextIndex = indexOfCurrentFile! + 1
            }
        }
        else{
            if indexOfCurrentFile! == 0{
                nextIndex = libraryCount - 1
            }
            else{
                nextIndex = indexOfCurrentFile! - 1
            }
        }
        let newFile = data.collection.library[nextIndex] as! File
        updateMetadataTable(newFile: newFile)
        contentWindow?.newMetadataAndNotes(notes: noteBody, metadata: selectedItemMetadata)
    }
    
    
    /// When the notification is sent from the the collectionView that a double click has occured, this method is called.
    /// If there is something selected, and it isn't already open, this method open a new content window for it and then
    /// adds it's path to the array keeping track of all the currently opened windows.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onDoubleClickReceived(_ notification:Notification){
        if (!(collection!.selectionIndexes.count == 0)) && !(currentlyOpenWindows.contains((ViewController.currentlySelectedFile?.path)!)){
            currentlyOpenWindows.append((ViewController.currentlySelectedFile?.path)!)
            contentWindow = ContentWindow(notes: noteBody, metadata: selectedItemMetadata)
            contentWindow?.showWindow(nil)
           collection.deselectAll(nil)
        }
    }
    
    /// When the notification is sent from that a reload is requested, this method is called.
    /// It just reloads the library using the function.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onReloadLibrary(_ notification:Notification){
        reloadLibrary()
    }
    
    /// When the notification is sent from that a file has been dragged and dropped, this method is called.
    /// Depending on they type of file that is dropped, we create a new appropriate file for it.
    /// We also get the date created and date modified using different formatters.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onDropItem(_ notification:Notification){
        let filePath = notification.userInfo!["filePath"] as! String
        let filePathSplit = filePath.components(separatedBy: "/")
        let filename = filePathSplit[filePathSplit.endIndex-1];
        let fileNameSplit = filePath.components(separatedBy: ".")
        let extensionType = fileNameSplit[1]
        let username = NSUserName()
        let url = NSURL(fileURLWithPath: filePath)
        let fileManager = FileManager.default
        var attributes : [FileAttributeKey : Any]
        var dateData = [Metadata]()
        do {
            attributes = try fileManager.attributesOfItem(atPath: filePath)
            let formatter = DateFormatter()
            let todayDate = Date()
            formatter.dateFormat = "dd-MMM-yyyy"
            let dateAdded = formatter.string(from: todayDate)
            let dateAddedMetadata = Metadata(keyword: "date-added", value: dateAdded)
            let dateModified = formatter.string(from: attributes[FileAttributeKey.modificationDate] as! Date)
            let dateModifiedMetadata = Metadata(keyword: "date-modified", value: dateModified)
            dateData.append(dateAddedMetadata)
            dateData.append(dateModifiedMetadata)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        if extensionType == "pdf" || extensionType == "txt"{
            let doc = Document(filename: filename, path: filePath, metadata: dateData, creator: username, notes: "")
            library.add(file: doc as File)
        }
        else if extensionType == "m4a" {
            let asset = AVAsset(url: url as URL)
            let duration = asset.duration;
            let runtime = CMTimeGetSeconds(duration);
            let stringRuntime =  String(describing: runtime)
            let runtimeArray = stringRuntime.components(separatedBy: ".")
            let runtimeFinal = runtimeArray[0]
            let audio = Audio(filename: filename, path: filePath, metadata: dateData, creator: username, runtime: runtimeFinal, notes: "")
            library.add(file: audio as File)
        }
        else if extensionType == "mov" {
            let asset = AVAsset(url: url as URL)
            let duration = asset.duration;
            let runtime = CMTimeGetSeconds(duration)
            let stringRuntime =  String(describing: runtime)
            let runtimeArray = stringRuntime.components(separatedBy: ".")
            let runtimeFinal = runtimeArray[0]
        
            let track = AVURLAsset(url: url as URL).tracks(withMediaType: AVMediaType.video).first
            let size = track?.naturalSize.applying((track?.preferredTransform)!)
            let videoStringSize =  String(describing: size)
            let videoResolution = videoStringSize.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ",", with: " x ")
            let video = Video(filename: filename, path: filePath, metadata: dateData, creator: username, resolution: videoResolution, runtime: runtimeFinal, notes: "")
            library.add(file: video as File)

        }
        else if extensionType == "jpg" || extensionType == "png"{
            let image = NSImage(contentsOfFile: filePath)
            let imageSize = image?.size
            let imageSizeString =  String(describing: imageSize)
            let temp = imageSizeString.replacingOccurrences(of: "Optional(", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: ",", with: " x ")
            let imageResolution = temp
            let imageFile = Image(filename: filename, path: filePath, metadata: dateData, creator: username, resolution: imageResolution, notes: "")
            library.add(file: imageFile as File)
        }
        reloadLibrary()
    }
    
    /// When the content window is closed it pushes this notification and this will update the array of currently
    /// open windows to remove it.
    /// - Parameters:
    /// - notification: The notification sent
    @objc func onWindowClosed(_ notification:Notification){
        let index = currentlyOpenWindows.index(of: notification.userInfo!["info"] as! String )
        currentlyOpenWindows.remove(at: index!)
    }
    
    /// Removes observers from the Notification Center.
    override func viewWillDisappear() {
        NotificationCenter.default.removeObserver(self)
    }
 

    ///  This method deals with the changes that need to occur when the user selects an item from the collection view.
    ///  This method first changes the items selected state to true which will update the color. It then changes the appropriate outlets
    ///  visibility. It then sets the static currentlySelectedFile variable to be the new file and updates the metadataArray which is connected to
    ///  the array controller via the updateMetadataTable method.
    /// - Parameters:
    /// - collectionView: the collection view calling the method
    /// - indexPaths: the index paths of the selected item(s)
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first
            else { return }
        guard let item = collectionView.item(at: indexPath) as? CollectionViewItem
            else { return }
        item.isSelected = true
        if bookmarkArray.count > 5{
            outletPopUp.isHidden = false
            addToBookmarksButton.isHidden = false
        }
        else{
            outletPopUp.isHidden = true
            addToBookmarksButton.isHidden = true
        }
        minusMetadataButton!.isEnabled = true
        addMetadataButton!.isEnabled = true
        noteBody.isHidden = false
        noteTitle.isHidden = false
        selecteditemIndexPath = indexPaths
        var index = Array(indexPaths)
        let clickedItem = data.collection.library[index[0][1]] as! File
        updateMetadataTable(newFile: clickedItem)
    }

    ///  This method deals with the changes that need to occur when the user deselects an item from the collection view.
    ///  This method changes the visibility of items appropriately and empties the metadata table.
    /// - Parameters:
    /// - collectionView: the collection view calling the method
    /// - indexPaths: the index paths of the deselected item(s)
    func collectionView(_ collectionView: NSCollectionView,
                        didDeselectItemsAt indexPaths: Set<IndexPath>){
        minusMetadataButton!.isEnabled = false
        addMetadataButton!.isEnabled = false
        noteBody.isHidden = true
        noteTitle.isHidden = true
        outletPopUp.isHidden = true
        addToBookmarksButton.isHidden = true
        metadataArrayController.remove(contentsOf: selectedItemMetadata as! [Any])
    }

    /// This method deals with the note section changing.
    /// These notes are set to be the note variable of the file
    /// - Parameters:
    /// - obj: the notification message
    override func controlTextDidChange(_ obj: Notification) {
        ViewController.currentlySelectedFile?.notes = noteBody.stringValue
    }
}

