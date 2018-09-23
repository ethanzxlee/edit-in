//
//  AppDelegate.swift
//  Edit In
//
//  Created by Zhe Xian Lee on 18/9/18.
//  Copyright © 2018 Zhe Xian Lee. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationWillFinishLaunching(_ aNotification: Notification) {
        UserDefaultsHelper.prepareUserDefaults()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        
    }


}

