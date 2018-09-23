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


class PhotoEditingViewController: NSViewController, PHContentEditingController {
    
    static let adjustmentDataFormatIdentifier = "app.zxlee.edit-in"
    static let adjustmentDataFormatVersion = "1.0.0"
    
    var input: PHContentEditingInput!
    var importURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        UserDefaultsHelper.clearUserDefaults()
        UserDefaultsHelper.prepareUserDefaults()
    }
    
    // MARK: - PHContentEditingController
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        return adjustmentData.formatIdentifier == PhotoEditingViewController.adjustmentDataFormatIdentifier &&
            adjustmentData.formatVersion == PhotoEditingViewController.adjustmentDataFormatVersion
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        input = contentEditingInput
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
    }
    
    // MARK: - IBActions
    
    @IBAction func handleOpenImage(_ sender: Any) {
        if let fullSizeImageURL = input.fullSizeImageURL {
            do {
                try copyImageToCache()
                openImageExternally()
            } catch {
                // TODO: Display error
                print(error)
            }
        } else {
            // TODO: Display error
            print("Full size image url is nil")
        }
    }
    
    // MARK: - Methods
    
    var cacheURL: URL {
        let fileManager = FileManager.default
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let useDefaultCachePath = userDefaults.bool(forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue)
        let customCachePath = userDefaults.string(forKey: UserDefaultsHelper.Keys.customCachePath.rawValue) ?? ""
        let defaultCacheURL = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        if useDefaultCachePath && customCachePath == "" {
            return defaultCacheURL
        }
        else {
            var isDirectory = ObjCBool(true)
            let exists = fileManager.fileExists(atPath: customCachePath, isDirectory: &isDirectory)
            let customCacheURL = URL(fileURLWithPath: customCachePath)
            
            if !exists && isDirectory.boolValue {
                do {
                    try fileManager.createDirectory(at: customCacheURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    // TODO: Display error
                    print("Error creating custom cache directory")
                    return defaultCacheURL
                }
            }
            return customCacheURL
        }
    }
    
    var cacheImageURL: URL {
        return cacheURL.appendingPathComponent(input.fullSizeImageURL!.lastPathComponent)
    }
    
    func copyImageToCache() throws {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: cacheImageURL.path) {
            try FileManager.default.copyItem(at: input.fullSizeImageURL!, to: cacheImageURL)
        }
    }
    
    func openImageExternally() {
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let preferredApplicationPath = userDefaults.string(forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)!
        NSWorkspace.shared.openFile(cacheImageURL.path, withApplication: URL(fileURLWithPath: preferredApplicationPath).path)
    }
    
    func importPhoto() {
        // Show OpenFilePanel
        // get the url into importURL
    }
    
}
