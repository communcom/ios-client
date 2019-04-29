//
//  FeedTimeFrameMode.swift
//  Commun
//
//  Created by Chung Tran on 29/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension FeedTimeFrameMode {
    #warning("missing wilsonHot & wilsonTrending")
    func toString() -> String {
        switch self {
        case .day:
            return "Past 24 hours".localized()
        case .week:
            return "Past Week".localized()
        case .month:
            return "Past Month".localized()
        case .year:
            return "Past Year".localized()
        case .all:
            return "Of All Time".localized()
        case .wilsonHot:
            return ""
        case .wilsonTrending:
            return ""
        }
    }
    
    static var allCases: [FeedTimeFrameMode] {
        return [.day, .week, .month, .year, .all]
    }
}
