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
            return "new".localized().uppercaseFirst
        case .popular:
            return "top".localized().uppercaseFirst
        case .time:
            return "old".localized().uppercaseFirst
        }
    }
    
    static var allCases: [FeedSortMode] {
        return [.popular, .timeDesc, .time]
    }
}
