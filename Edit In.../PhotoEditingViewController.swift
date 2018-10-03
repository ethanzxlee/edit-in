//
//  PhotoEditingViewController.swift
//  Edit In...
//
//  Created by Zhe Xian Lee on 18/9/18.
//  Copyright © 2018 Zhe Xian Lee. All rights reserved.
//

import Cocoa
import Photos
import PhotosUI
import os

class PhotoEditingViewController: NSViewController, PHContentEditingController {
    
    static let adjustmentDataFormatIdentifier = "app.zxlee.edit-in"
    static let adjustmentDataFormatVersion = "0.0.1"
    
    let cacheDirectoryURL: URL = {
        let fileManager = FileManager.default
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let useDefaultCachePath = userDefaults.bool(forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue)
        let customCachePath = userDefaults.string(forKey: UserDefaultsHelper.Keys.customCachePath.rawValue) ?? ""
        let defaultCacheURL = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let defaultEditCacheURL = defaultCacheURL.appendingPathComponent("edits")
        try! fileManager.createDirectory(at: defaultEditCacheURL, withIntermediateDirectories: true, attributes: nil)
        
        if useDefaultCachePath || customCachePath == "" {
            return defaultEditCacheURL
        } else {
            var isDirectory = ObjCBool(true)
            let exists = fileManager.fileExists(atPath: customCachePath, isDirectory: &isDirectory)
            let customCacheURL = URL(fileURLWithPath: customCachePath)
            
            if !exists {
                do {
                    try fileManager.createDirectory(at: customCacheURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    os_log("Could not open the custom cache direcory, will be using the default cache directory", log: OSLog.default, type: .info)
                    return defaultEditCacheURL
                }
            }
            return customCacheURL
        }
    }()
    
    var cachedOriginalImageURL: URL? {
        if let filename = editingInput.fullSizeImageURL?.lastPathComponent {
            return cacheDirectoryURL.appendingPathComponent(filename)
        }
        os_log("Tried to get cachedOriginalImageURL when input is nil", log: OSLog.default, type: .info)
        return nil
    }
    
    var editingInput: PHContentEditingInput!
    var editedImageURL: URL? {
        didSet {
            if editedImageURL != nil {
                importedImageTextField.stringValue = editedImageURL!.path
            }
        }
    }
    var editedImage: NSImage?
    var importEditedImagePanel: NSOpenPanel?
    var editorAppURLs: [URL] = []
    
    @IBOutlet weak var importedImageTextField: NSTextField!
    @IBOutlet weak var importImageButton: NSButton!
    @IBOutlet weak var editorAppPopUpButton: NSPopUpButton!
    @IBOutlet weak var compareButton: NSButton!
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var imageScrollView: NSScrollView!
    @IBOutlet weak var clipView: CenteringClipView!
    @IBOutlet weak var documentViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var documentViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaultsHelper.prepareUserDefaults()
    }
    
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return adjustmentData.formatIdentifier == PhotoEditingViewController.adjustmentDataFormatIdentifier &&
            adjustmentData.formatVersion == PhotoEditingViewController.adjustmentDataFormatVersion
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        editingInput = contentEditingInput
        populateEditorAppMenu()
        
        if let inputImage = editingInput.displaySizeImage {
            imageView.image = inputImage
            showImage(inputImage)
        } else {
            imageView.image = nil
        }
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        DispatchQueue.global().async {
            guard let editingInput = self.editingInput, let editedImageURL = self.editedImageURL  else {
                return
            }
            
            if FileManager.default.fileExists(atPath: editedImageURL.path) {
                do {
                    let output = PHContentEditingOutput(contentEditingInput: editingInput)
                    output.adjustmentData = PHAdjustmentData(formatIdentifier: PhotoEditingViewController.adjustmentDataFormatIdentifier, formatVersion: PhotoEditingViewController.adjustmentDataFormatVersion, data: Data())
                    try FileManager.default.copyItem(at: editedImageURL, to: output.renderedContentURL)
                    completionHandler(output)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        return editedImageURL != nil && editedImage != nil
    }
    
    func cancelContentEditing() {
        let fileManager = FileManager.default
        do {
            for filePath in try fileManager.contentsOfDirectory(atPath: cacheDirectoryURL.path) {
                do {
                    let absoluteFilePath = cacheDirectoryURL.appendingPathComponent(filePath).path
                    try fileManager.removeItem(atPath: absoluteFilePath)
                } catch {
                    os_log("Failed to remove item when clearing cache", log: OSLog.default, type: .info)
                }
            }
        } catch {
            os_log("Failed to list contents of the cache directory when clearing cache", log: OSLog.default, type: .info)
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func handleOpenImage(_ sender: Any) {
        if editingInput.fullSizeImageURL != nil {
            do {
                let _ = requestPermissionToWrite(atURL: cacheDirectoryURL)
                try copyImageToCache()
                openImageExternally()
            } catch {
                // TODO: Display error
                print(error)
                os_log("Failed to open image", log: OSLog.default, type: .error)
            }
        } else {
            os_log("Tried to open image when input fullSizeImageURL is nil", log: OSLog.default, type: .error)
        }
    }
    
    @IBAction func handleImportEditedImage(_ sender: Any) {
        importEditedPhoto()
    }
    
    // MARK: - Methods
    
    func copyImageToCache() throws {
        guard let cachedOriginalImageURL = cachedOriginalImageURL else {
            os_log("Could not get cachedOriginalImageURL when copying image to cache directory", log: OSLog.default, type: .info)
            return
        }
        
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: cachedOriginalImageURL.path) {
            try fileManager.copyItem(at: editingInput.fullSizeImageURL!, to: cachedOriginalImageURL)
        }
    }

    func requestPermissionToWrite(atURL url: URL) -> Bool {
        let filename = "temp"
        let fileURL = url.appendingPathComponent(filename)
        if !FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.directoryURL = url
            panel.runModal()
            print(panel.urls)
            let canCreate = FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
            try? FileManager.default.removeItem(at: fileURL)
            return canCreate
        }
        try? FileManager.default.removeItem(at: fileURL)
        return true
    }
    
    func openImageExternally() {
        guard let cachedOriginalImageURL = cachedOriginalImageURL else {
            os_log("Could not get cachedOriginalImageURL when opening image", log: OSLog.default, type: .info)
            return
        }
        var preferredApplicationPath = editorAppURLs.first { (url) -> Bool in
            url.deletingPathExtension().lastPathComponent == editorAppPopUpButton.selectedItem?.title
        }?.path
        
        if preferredApplicationPath == nil {
            let userDefaults = UserDefaultsHelper.groupUserDefaults
            preferredApplicationPath = userDefaults.string(forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)!
        }
        
        let openSuccess = NSWorkspace.shared.openFile(cachedOriginalImageURL.path, withApplication: URL(fileURLWithPath: preferredApplicationPath!).path)
        if !openSuccess {
            // TODO: display error message
            os_log("Could not open image with selected application", log: .default, type: .error)
        }
    }
    
    func importEditedPhoto() {
        importEditedImagePanel?.close()
        importEditedImagePanel = NSOpenPanel()
        importEditedImagePanel!.allowsMultipleSelection = false
        importEditedImagePanel!.canChooseFiles = true
        importEditedImagePanel?.canChooseDirectories = false
        importEditedImagePanel!.allowedFileTypes = ["jpg","jpeg"]
        importEditedImagePanel!.directoryURL = URL(fileURLWithPath: cacheDirectoryURL.path)
        importEditedImagePanel!.beginSheetModal(for: NSApplication.shared.windows.first!) { (response) in
            if response == .OK {
                guard let importEditedImagePanel = self.importEditedImagePanel else {
                    return
                }
                guard let url = importEditedImagePanel.url else {
                    return
                }
                
                do {
                    let selectedFileType = try NSWorkspace.shared.type(ofFile: url.path)
                    if selectedFileType == kUTTypeJPEG as String {
                        self.editedImage = NSImage(contentsOf: url)
                        self.editedImageURL = url
                        
                        DispatchQueue.main.async {
                            self.imageView.image = self.editedImage
                            self.showImage(self.editedImage)
                        }
                    }
                } catch {
                    os_log("Could not determine the type of the file selected", log: OSLog.default, type: .info)
                }
            }
        }
    }
    
    func showImage(_ image: NSImage?) {
        if let image = image {
            imageView.image = image
            documentViewWidthConstraint.constant = image.size.width
            documentViewHeightConstraint.constant = image.size.height
            imageScrollView.magnify(toFit: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        }
    }
    
    func populateEditorAppMenu() {
        editorAppURLs = UserDefaultsHelper.editorApplicationURLs(for: editingInput.fullSizeImageURL?.path)
        
        let preferredApplicationPath = UserDefaultsHelper.groupUserDefaults.string(forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)!
        let editorMenu = NSMenu()
        editorMenu.items = editorAppURLs.map { (url) -> NSMenuItem in
            let title = url.deletingPathExtension().lastPathComponent
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            if url.path == preferredApplicationPath {
                menuItem.state = .on
            }
            return menuItem
        }
        
        editorAppPopUpButton.menu = editorMenu
    }
    
}
