//
//  ResponseAPIGetPostContent.swift
//  Commun
//
//  Created by Chung Tran on 10/9/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension ResponseAPIContentGetPostContent {
    var attachments: [ResponseAPIContentBlock] {
        let type = body.attributes?.type
        if type == "basic" {
            return body.content.arrayValue?.first(where: {$0.type == "attachments"})?.content.arrayValue ?? []
        }
        
        if type == "article" {
            return body.content.arrayValue?.filter {$0.type == "image" || $0.type == "video" || $0.type == "website"} ?? []
        }
        
        return []
    }
    
    var firstEmbedImageURL: String? {
        let type = body.attributes?.type
        if type == "basic" {
            return body.content.arrayValue?.first(where: {$0.type == "attachments"})?.content.arrayValue?.first?.attributes?.thumbnail_url
        }
        
        if type == "article" {
            return body.content.arrayValue?.first(where: {$0.type == "image" || $0.type == "video" || $0.type == "website"})?.attributes?.thumbnail_url
        }
        
        return nil
    }
}
