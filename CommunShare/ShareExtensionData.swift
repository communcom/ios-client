//
//  ShareExtensionData.swift
//  CommunShare
//
//  Created by Sergey Monastyrskiy on 31.01.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit

public class ShareExtensionData: NSObject, NSCoding {
    // MARK: - Properties
    var text: String?
    var link: String?
    var image: UIImage?
    

    // MARK: - Class Functions
    public func encode(with coder: NSCoder) {
        coder.encode(text, forKey: "text")
        coder.encode(link, forKey: "link")
        coder.encode(image, forKey: "image")
    }
    
    required convenience public init?(coder: NSCoder) {
        self.init()

        self.text = coder.decodeObject(forKey: "text") as? String
        self.link = coder.decodeObject(forKey: "link") as? String
        self.image = coder.decodeObject(forKey: "image") as? UIImage
    }
}
