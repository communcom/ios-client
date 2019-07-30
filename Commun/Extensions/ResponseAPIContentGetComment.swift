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
}
