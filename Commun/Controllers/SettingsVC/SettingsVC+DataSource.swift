//
//  SettingsVC+DataSource.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

// https://stackoverflow.com/questions/40455824/how-to-bind-table-view-with-multiple-sections-that-represent-different-data-type

extension SettingsVC {
    enum Section: SectionModelType {
        // Custom data
        enum CustomData {
            case option(SettingsOptionsCell.Option)
            case switcher(SettingsSwitcherCell.SwitcherType)
            case keyValue(SettingsKeyCell.KeyType)
            case button(SettingsButtonCell.ButtonType)
        }
        
        // Section
        case firstSection(header: String, items: [CustomData])
        case secondSection(header: String, items: [CustomData])
        case thirdSection(header: String, items: [CustomData])
        case forthSection(items: [CustomData])
        
        // SectionModelType
        typealias Item = CustomData
        var items: [CustomData] {
            switch self {
            case .firstSection(_, let items):
                return items
                
            case .secondSection(_, let items):
                return items
                
            case .thirdSection(_, let items):
                return items
                
            case .forthSection(let items):
                return items
            }
        }
        
        public init(original: Section, items: [CustomData]) {
            switch original {
            case .firstSection(let header, _):
                self = .firstSection(header: header, items: items)
                
            case .secondSection(let header, _):
                self = .secondSection(header: header, items: items)
                
            case .thirdSection(let header, _):
                self = .thirdSection(header: header, items: items)
                
            case .forthSection(_):
                self = .forthSection(items: items)
            }
        }
    }
}
