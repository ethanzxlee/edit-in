//
//  ViewController.swift
//  Edit In
//
//  Created by Zhe Xian Lee on 18/9/18.
//  Copyright © 2018 Zhe Xian Lee. All rights reserved.
//

import Foundation
import Cocoa
import CoreServices

class ViewController: NSViewController {

    @IBOutlet weak var selectCacheFolderButton: NSButton!
    @IBOutlet weak var customCacheLocationButton: NSButton!
    @IBOutlet weak var defaultCacheLocationButton: NSButton!
    @IBOutlet weak var customCacheLocationTextField: NSTextField!
    @IBOutlet weak var preferredAppPopUpButton: NSPopUpButton!
    
    var editorAppURLs: [URL] = []
    let groupUserDefaults = UserDefaultsHelper.groupUserDefaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaultsHelper.prepareUserDefaults()
        populateCacheLocationControls()
        populateEditorAppMenu()
    }

    @IBAction func setCacheLocationType(_ sender: Any) {
        if sender as? NSButton == defaultCacheLocationButton {
            groupUserDefaults.set(true, forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue)
            groupUserDefaults.synchronize()
            populateCacheLocationControls()
        } else if sender as? NSButton == customCacheLocationButton {
            if groupUserDefaults.string(forKey: UserDefaultsHelper.Keys.customCachePath.rawValue) == "" {
                let fileManager = FileManager.default
                let userDirectoryURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                let cacheDirectoryURL = userDirectoryURL.appendingPathComponent("EditInCache")
                groupUserDefaults.set(cacheDirectoryURL.path, forKey: UserDefaultsHelper.Keys.customCachePath.rawValue)
            }
            groupUserDefaults.set(false, forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue)
            groupUserDefaults.synchronize()
            populateCacheLocationControls()
        }
    }
    
    @IBAction func selectCacheLocation(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = URL(fileURLWithPath: customCacheLocationTextField.stringValue, isDirectory: true)
        openPanel.beginSheetModal(for: NSApplication.shared.mainWindow!) { (response) in
            if response == .OK {
                guard let url = openPanel.url else {
                    return
                }
                
                self.customCacheLocationTextField.stringValue = url.path
                self.groupUserDefaults.set(url.path, forKey: UserDefaultsHelper.Keys.customCachePath.rawValue)
                self.groupUserDefaults.synchronize()
            }
        }
    }
    
    @IBAction func preferredAppChanged(_ sender: Any) {
        guard let selectItemTitle = preferredAppPopUpButton.selectedItem?.title else {
            return
        }
        
        let selectedAppURL = editorAppURLs.first { (url) -> Bool in
            url.deletingPathExtension().lastPathComponent == selectItemTitle
        }
        
        if selectedAppURL != nil {
            groupUserDefaults.set(selectedAppURL!.path, forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)
            groupUserDefaults.synchronize()
        }
    }
    
    func populateCacheLocationControls() {
        if groupUserDefaults.bool(forKey: UserDefaultsHelper.Keys.useDefaultCachePath.rawValue) {
            defaultCacheLocationButton.state = .on
            customCacheLocationButton.state = .off
            customCacheLocationTextField.isEnabled = false
            selectCacheFolderButton.isEnabled = false
            customCacheLocationTextField.stringValue = ""
        } else {
            defaultCacheLocationButton.state = .off
            customCacheLocationButton.state = .on
            customCacheLocationTextField.isEnabled = true
            selectCacheFolderButton.isEnabled = true
            customCacheLocationTextField.stringValue = groupUserDefaults.string(forKey: UserDefaultsHelper.Keys.customCachePath.rawValue) ?? ""
        }
    }
    
    func populateEditorAppMenu() {
        editorAppURLs = UserDefaultsHelper.editorApplicationURLs()
        
        let userDefaults = UserDefaultsHelper.groupUserDefaults
        let preferredApplicationPath = userDefaults.string(forKey: UserDefaultsHelper.Keys.preferredApplicationPath.rawValue)
        
        let editorMenu = NSMenu()
        editorMenu.items = editorAppURLs.map { (url) -> NSMenuItem in
            let title = url.deletingPathExtension().lastPathComponent
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            if url.path == preferredApplicationPath {
                menuItem.state = .on
            }
            return menuItem
        }
        
        preferredAppPopUpButton.menu = editorMenu
    }
}

