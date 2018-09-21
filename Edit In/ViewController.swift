//
//  ViewController.swift
//  Edit In
//
//  Created by Zhe Xian Lee on 18/9/18.
//  Copyright © 2018 Zhe Xian Lee. All rights reserved.
//

import Cocoa
import CoreServices

class ViewController: NSViewController {
    
    
    func prepareUserDefaults() {
        let ud = UserDefaults(suiteName: "group.app.zxlee.Edit-In")!
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
}

