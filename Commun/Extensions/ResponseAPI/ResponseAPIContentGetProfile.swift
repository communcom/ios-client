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

extension ResponseAPIContentGetProfile: IdentifiableType {
    public var identity: String {
        return userId + "/" + username
    }
}
