//
//  URL.swift
//  Commun
//
//  Created by Chung Tran on 9/18/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension URL {
    #if !APPSTORE
    static var appDomain    =   "dev.commun.com"
    #else
    static var appDomain    =   "commun.com"
    #endif
    static var appURL       =   "https://\(appDomain)"
    
    static func string(_ string: String, isValidURLWithExtension ext: String) -> Bool {
        ext == (string as NSString).pathExtension
    }
    
    static func string(_ string: String, isImageURLIncludeGIF gifIncluded: Bool = true) -> Bool {
        var imageFormats = ["jpg", "png"]
        if gifIncluded {
            imageFormats.append("gif")
        }
        
        for format in imageFormats {
            if Self.string(string, isValidURLWithExtension: format) {
                return true
            }
        }
        return false
    }
}
