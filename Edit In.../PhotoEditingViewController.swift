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
    static let adjustmentDataFormatVersion = "1.0.0"
    
    let cacheDirectoryURL: URL = {
        let fileManager = FileManager.default
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let useDefaultCachePath = userDefaults.bool(forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue)
        let customCachePath = userDefaults.string(forKey: UserDefaultsHelper.Keys.customCachePath.rawValue) ?? ""
        let defaultCacheURL = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if useDefaultCachePath && customCachePath == "" {
            return defaultCacheURL
        } else {
            var isDirectory = ObjCBool(true)
            let exists = fileManager.fileExists(atPath: customCachePath, isDirectory: &isDirectory)
            let customCacheURL = URL(fileURLWithPath: customCachePath)
            
            if !exists && isDirectory.boolValue {
                do {
                    try fileManager.createDirectory(at: customCacheURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    os_log("Could not open the custom cache direcory, will be using the default cache directory", log: OSLog.default, type: .info)
                    return defaultCacheURL
                }
            }
            return customCacheURL
        }
    }()
    
    var cachedOriginalImageURL: URL? {
        if let filename = input.fullSizeImageURL?.lastPathComponent {
            return cacheDirectoryURL.appendingPathComponent(filename)
        }
        os_log("Tried to get cachedOriginalImageURL when input is nil", log: OSLog.default, type: .info)
        return nil
    }
    
    var input: PHContentEditingInput!
    var importURL: URL?
    
    @IBOutlet weak var importedImageTextField: NSTextField!
    @IBOutlet weak var importImageButton: NSButton!
    @IBOutlet weak var applicationsPopUpButton: NSPopUpButton!
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
        input = contentEditingInput
        if let inputImage = input.displaySizeImage {
            imageView.image = inputImage
            documentViewWidthConstraint.constant = inputImage.size.width
            documentViewHeightConstraint.constant = inputImage.size.height
            imageScrollView.magnify(toFit: NSRect(x: 0, y: 0, width: inputImage.size.width, height: inputImage.size.height))
        } else {
            imageView.image = nil
        }
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // TODO: Display saving
        DispatchQueue.global().async {
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            // copy content of importURL into output.renderedContentURL
            completionHandler(output)
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        return importURL != nil
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
        if input.fullSizeImageURL != nil {
            do {
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
            try FileManager.default.copyItem(at: input.fullSizeImageURL!, to: cachedOriginalImageURL)
        }
    }
    
    func openImageExternally() {
        guard let cachedOriginalImageURL = cachedOriginalImageURL else {
            os_log("Could not get cachedOriginalImageURL when opening image", log: OSLog.default, type: .info)
            return
        }
        
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let preferredApplicationPath = userDefaults.string(forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)!
        let openSuccess = NSWorkspace.shared.openFile(cachedOriginalImageURL.path, withApplication: URL(fileURLWithPath: preferredApplicationPath).path)
        if !openSuccess {
            // TODO: display error message
            os_log("Could not open image with selected application", log: .default, type: .error)
        }
    }
    
    func importEditedPhoto() {
        // Show OpenFilePanel
        // get the url into importURL
        
    }
    
}
