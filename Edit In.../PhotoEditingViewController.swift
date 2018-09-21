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
    
    var input: PHContentEditingInput?
    var importURL: URL?
    var cacheURL: URL?
    var isPhotoshopInstalled = false

    // Preferences
    // - Auto Open
    // - Photoshop Location
    // - Cache Location
    //
    //first
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let ud = UserDefaults.standard
//        print(ud.dictionaryRepresentation())
//        print("viewDidLoad()")

        let ud = UserDefaults(suiteName: "group.app.zxlee.Edit-In")!
        print(ud.object(forKey: "emotion"))
        
        // check if photoshop is installed
        // if not installed, show a notice
        // make sure touchbar button is disabled
        // need to check if this is called first or startContentEditing
        
    }

    // MARK: - PHContentEditingController
    //second
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        print("canHandle()")
        print("formatIdentidier: \(adjustmentData.formatIdentifier)")
        print("formatVersion \(adjustmentData.formatIdentifier)")
        return adjustmentData.formatIdentifier == PhotoEditingViewController.adjustmentDataFormatIdentifier &&
            adjustmentData.formatVersion == PhotoEditingViewController.adjustmentDataFormatVersion
    }
    //third
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: NSImage) {
        print("startContentEditing()")
        input = contentEditingInput
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
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
    
    // MARK: - Methods
    
    func openPhoto() {
        // Open file in photoshop
    }
    
    func importPhoto() {
        // Show OpenFilePanel
        // get the url into importURL
    }

}
