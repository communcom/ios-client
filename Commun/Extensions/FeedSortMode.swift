//
//  FeedTypeMode.swift
//  Commun
//
//  Created by Chung Tran on 25/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

extension FeedSortMode {
    func toString() -> String {
        switch self {
        case .timeDesc:
            return "New".localized()
        case .popular:
            return "Top".localized()
        case .time:
            return "Old".localized()
        }
    }
    
    static var allCases: [FeedSortMode] {
        return [.popular, .timeDesc, .time]
    }
}
