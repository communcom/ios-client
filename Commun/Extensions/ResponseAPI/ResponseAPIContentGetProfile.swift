//
//  ResponseAPIContentGetProfile.swift
//  Commun
//
//  Created by Chung Tran on 25/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

extension ResponseAPIContentGetProfile: Equatable, IdentifiableType {
    public static func == (lhs: ResponseAPIContentGetProfile, rhs: ResponseAPIContentGetProfile) -> Bool {
        return lhs.identity == rhs.identity
    }
    
    public var identity: String {
        return userId + "/" + (username ?? "")
    }
    
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: ProfileControllerProfileDidChangeNotification), object: self)
    }
}
