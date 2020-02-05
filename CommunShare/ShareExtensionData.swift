//
//  ShareExtensionData.swift
//  CommunShare
//
//  Created by Sergey Monastyrskiy on 31.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit

public struct ShareExtensionData: Codable { //NSObject, NSCoding {
    // MARK: - Properties
    var text: String?
    var link: String?
    var imageData: Data?
}
//    
//    // MARK: - Class Functions
//    public func encode(with coder: NSCoder) {
//        coder.encode(text, forKey: "text")
//        coder.encode(link, forKey: "link")
//        coder.encode(imageData, forKey: "imageData")
//    }
//    
//    required convenience public init?(coder: NSCoder) {
//        self.init()
//
//        self.text = coder.decodeObject(forKey: "text") as? String
//        self.link = coder.decodeObject(forKey: "link") as? String
//        self.imageData = coder.decodeObject(forKey: "imageData") as? Data
//    }
//}
