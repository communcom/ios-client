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

let CommentControllerCommentDidChangeNotification = "CommentControllerCommentDidChangeNotification"

extension ResponseAPIContentGetComment: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetComment, rhs: ResponseAPIContentGetComment) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
    
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: CommentControllerCommentDidChangeNotification), object: self)
    }
    
    public var firstEmbedImageURL: String? {
        let embeds = content.embeds
        if embeds.count > 0,
            let imageURL = embeds[0].result?.thumbnail_url ?? embeds[0].result?.url {
            return imageURL
        }
        return nil
    }

}
