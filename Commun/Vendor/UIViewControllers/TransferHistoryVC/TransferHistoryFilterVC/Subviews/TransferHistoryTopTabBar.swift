//
//  TransferHistoryTopTabBar.swift
//  Commun
//
//  Created by Chung Tran on 12/24/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

class TransferHistoryTopTabBar: CMTopTabBar {
    override func changeSelectedIndex(_ index: Int) {
        if index == selectedIndex.value {
            selectedIndex.accept(-1)
        } else {
            selectedIndex.accept(index)
        }
    }
}
