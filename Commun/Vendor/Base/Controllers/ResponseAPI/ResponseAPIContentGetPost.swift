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

extension ResponseAPIContentGetPost: IdentifiableType {
    public var identity: String {
        return self.contentId.userId + "/" + self.contentId.permlink
    }
    
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "\(Self.self)DidChange"), object: self)
    }
    
    public var content: [ResponseAPIContentBlock]? {
        return document?.content.arrayValue
    }
}
