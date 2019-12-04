//
//  HighlightCommunityCell.swift
//  Commun
//
//  Created by Chung Tran on 12/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension ResponseAPIContentGetProfileCommonCommunity: CommunityType {
    var subscribersCount: UInt64? {
        get {
            return nil
        }
        set {
            
        }
    }
    
    public var identity: String {
        return communityId + "/" + name
    }
}

class HighlightCommunityCell: CommunityCollectionCell<ResponseAPIContentGetProfileCommonCommunity> {
    
}

