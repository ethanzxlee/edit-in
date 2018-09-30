//
//  UserDefaultsHelper.swift
//  Edit In
//
//  Created by Zhe Xian Lee on 22/9/18.
//  Copyright © 2018 Zhe Xian Lee. All rights reserved.
//

import Foundation

class UserDefaultsHelper {
    static let suiteName = "group.app.zxlee.Edit-In"
    static let previewPath = "/Applications/Preview.app/"
    static let testJPEGName = "TestJPEG"
    static let photoshopPattern = "Adobe Photoshop.*\\.app"
    
    enum Keys: String {
        case useDefaultCachePath = "USE_DEFAULT_CACHE_PATH"
        case customCachePath = "CUSTOM_CACHE_PATH"
        case preferredApplicationPath = "PREFERRED_APPLICATION_PATH"
    }
    
    static func editorApplicationURLs(for imageAtPath: String? = nil) -> [URL] {
        let imagePath = imageAtPath ?? Bundle.main.pathForImageResource(testJPEGName)!
        let imageURL = URL(fileURLWithPath: imagePath)
        let applicationURLs = LSCopyApplicationURLsForURL(imageURL as CFURL, .editor)!.takeRetainedValue() as Array
        let urls = applicationURLs.map { (url) -> URL in
            url as! URL
        }
        return urls
    }
    
    static var groupUserDefaults: UserDefaults {
        return UserDefaults(suiteName: suiteName)!
    }
    
    static func clearUserDefaults() {
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removeObject(forKey: Keys.useDefaultCachePath.rawValue)
        userDefaults.removeObject(forKey: Keys.customCachePath.rawValue)
        userDefaults.removeObject(forKey: Keys.preferredApplicationPath.rawValue)
    }
    
    
    /**
     Make sure the user default values are set
     */
    static func prepareUserDefaults() {
        let userDefaults = groupUserDefaults
        
        if (userDefaults.object(forKey: Keys.useDefaultCachePath.rawValue) == nil) {
            userDefaults.set(true, forKey: Keys.useDefaultCachePath.rawValue)
            userDefaults.set("", forKey: Keys.customCachePath.rawValue)
        }
        
        let preferredApplicationPath = userDefaults.object(forKey: Keys.preferredApplicationPath.rawValue) as? String
        
        if (preferredApplicationPath == nil || !FileManager.default.fileExists(atPath: preferredApplicationPath ?? "")) {
            // Set Photoshop as preferred application if found,
            // Otherwise set Preview as preferred application
            let photoshopRegex = try! NSRegularExpression(pattern: photoshopPattern, options: .caseInsensitive)
            let photoshopURLs = editorApplicationURLs().filter { (url) -> Bool in
                let urlString = url.path
                let matches = photoshopRegex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
                return matches.count > 0
            }
            
            if (photoshopURLs.first != nil) {
                userDefaults.set(photoshopURLs.first!.path, forKey: Keys.preferredApplicationPath.rawValue)
            } else {
                userDefaults.set(previewPath, forKey: Keys.preferredApplicationPath.rawValue)
            }
        }
    }
}
