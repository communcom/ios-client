//
//  ResponseAPIContentGetCommunity.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetCommunity: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetCommunity, rhs: ResponseAPIContentGetCommunity) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return (communityId ?? "") + "/" + (name ?? "")
    }
}
