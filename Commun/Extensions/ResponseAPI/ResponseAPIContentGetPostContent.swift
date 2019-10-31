//
//  ResponseAPIGetPostContent.swift
//  Commun
//
//  Created by Chung Tran on 10/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension ResponseAPIContentGetPost {
    var attachments: [ResponseAPIContentBlock] {
        let type = document?.attributes?.type
        if type == "basic" {
            return content?.first(where: {$0.type == "attachments"})?.content.arrayValue ?? []
        }
        
        if type == "article" {
            return content?.filter {$0.type == "image" || $0.type == "video" || $0.type == "website"} ?? []
        }
        
        return []
    }
    
    var firstEmbedImageURL: String? {
        let type = document?.attributes?.type
        if type == "basic" {
            return content?.first(where: {$0.type == "attachments"})?.content.arrayValue?.first?.attributes?.thumbnail_url
        }
        
        if type == "article" {
            return content?.first(where: {$0.type == "image" || $0.type == "video" || $0.type == "website"})?.attributes?.thumbnail_url
        }
        
        return nil
    }
}
