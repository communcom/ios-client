//
//  ResponseAPIContentGetPost.swift
//  Commun
//
//  Created by Chung Tran on 20/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetPost: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetPost, rhs: ResponseAPIContentGetPost) -> Bool {
        return lhs.identity == rhs.identity &&
            lhs.content.title == rhs.content.title &&
            lhs.content.tags == rhs.content.tags &&
            lhs.content.body.preview == rhs.content.body.preview &&
            lhs.content.body.full == rhs.content.body.full &&
            lhs.votes.upCount == rhs.votes.upCount &&
            lhs.votes.downCount == rhs.votes.downCount &&
            lhs.votes.hasUpVote == rhs.votes.hasUpVote &&
            lhs.votes.hasDownVote == rhs.votes.hasDownVote
    }
    
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
}
