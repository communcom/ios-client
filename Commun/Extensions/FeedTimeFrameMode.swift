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
            return "past 24 hours".localized().uppercaseFirst
        case .week:
            return "past week".localized().uppercaseFirst
        case .month:
            return "past month".localized().uppercaseFirst
        case .year:
            return "past year".localized().uppercaseFirst
        case .all:
            return "of all time".localized().uppercaseFirst
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
