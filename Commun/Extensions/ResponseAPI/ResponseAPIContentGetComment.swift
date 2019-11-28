//
//  ResponseAPIContentGetComment.swift
//  Commun
//
//  Created by Chung Tran on 7/30/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources


extension ResponseAPIContentGetComment: IdentifiableType {
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
    
    var content: [ResponseAPIContentBlock]? {
        return document.content.arrayValue
    }
    
    var firstEmbedImageURL: String? {
        return content?.first(where: {$0.type == "attachments"})?.content.arrayValue?.first?.attributes?.thumbnailUrl
    }
    
    var attachments: [ResponseAPIContentBlock] {
        return content?.first(where: {$0.type == "attachments"})?.content.arrayValue ?? []
    }
    
    mutating func addChildComment(_ comment: ResponseAPIContentGetComment) {
        children = (children ?? []) + [comment]
        childCommentsCount = childCommentsCount + 1
        notifyChanged()
        notifyChildrenChanged()
    }
}
