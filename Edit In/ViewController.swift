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
    

    
//    func prepareUserDefaults() {
//        let userDefaults = UserDefaults(suiteName: "group.app.zxlee.Edit-In")!
//
//        if (userDefaults.object(forKey: "USE_DEFAULT_CACHE_LOCATION") == nil) {
//            userDefaults.set(true, forKey: "USE_DEFAULT_CACHE_LOCATION")
//            userDefaults.set("", forKey: "CUSTOM_CACHE_LOCATION")
//        }
//
//
//        if (userDefaults.object(forKey: "PREFERRED_APPLICATION") == nil) {
//            let testJPEGPath = Bundle.main.pathForImageResource("TestJPEG")!
//            let testJPEFURL = URL(string: testJPEGPath)!
//            let applicationURLs = LSCopyApplicationURLsForURL(testJPEFURL as CFURL, .editor)
//        }
//
//        print(Bundle.main.pathForImageResource("TestJPEG"))
//
//        let defaultCacheLocation = try! FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//        print("default Cache Location \(defaultCacheLocation)")
//        print("temp: \(FileManager.default.temporaryDirectory)")
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        prepareUserDefaults()
        
//        let bundle = Bundle.main
//        print(bundle.infoDictionary)
        
//        let ud = UserDefaults.standard
//        ud.addSuite(named: "app.zxlee.Edit-In.Edit-In---")
//        print(ud.object(forKey: "emotion"))
//        ud.set("happy", forKey: "emotion")
//        print(ud.object(forKey: "emotion"))
        
//        let ud = UserDefaults(suiteName: "group.app.zxlee.Edit-In")!
//        print(ud.object(forKey: "emotion"))
//        ud.set("happy", forKey: "emotion")
//        print(ud.object(forKey: "emotion"))
   
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func setCacheLocationType(_ sender: Any) {
    }
    
    
    @IBAction func selectFile(_ sender: Any) {
        let dialog = NSOpenPanel()
        if (dialog.runModal() == .OK) {
            let fileURL = dialog.url! as CFURL
            
        
            let applicationURLs = LSCopyApplicationURLsForURL(fileURL, .editor)
            
            let apps = applicationURLs?.takeRetainedValue() as? Array<NSURL>
          
            let workspace = NSWorkspace.shared
            for app in apps! {
                
                    let icon = workspace.icon(forFile: app.absoluteString!)
                
                    print(icon)
            }
            
            
            
        }
    }
    
//    func createTestJPEG() {
//        let context = CGContext(data: nil, width: 1, height: 1, bitsPerComponent: 1, bytesPerRow: 8, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0)
//        NSImage(
//        
//    }
    
}

