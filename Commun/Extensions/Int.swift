//
//  Int.swift
//  Commun
//
//  Created by Chung Tran on 2/11/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension Int {
    var kmFormatted: String {
        Double(self).kmFormatted()
    }
}

extension Int64 {
    var kmFormatted: String {
        Double(self).kmFormatted()
    }
}
