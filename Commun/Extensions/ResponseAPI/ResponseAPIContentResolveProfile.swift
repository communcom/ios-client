//
//  ResponseAPIContentResolveProfile.swift
//  Commun
//
//  Created by Chung Tran on 10/24/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentResolveProfile: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentResolveProfile, rhs: ResponseAPIContentResolveProfile) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return userId + "/" + username
    }
}
