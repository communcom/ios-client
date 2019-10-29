//
//  ResponseAPIContentGetLeader.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetLeader: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetLeader, rhs: ResponseAPIContentGetLeader) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return userId
    }
}
