//
//  Double.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension Double {
    func kmFormatted(maximumFractionDigit: Int = 1) -> String {
        if self.isNaN {
            return "NaN"
        }
        if self.isInfinite {
            return "\(self < 0.0 ? "-" : "+")Infinity"
        }
        let units = ["", "k", "M"]
        var interval = self
        var i = 0
        while i < units.count - 1 {
            if interval.abs < 1000 {
                break
            }
            i += 1
            interval /= 1000.0
        }
        // + 2 to have one digit after the comma, + 1 to not have any.
        // Remove the * and the number of digits argument to display all the digits after the comma.
        if interval <= 0 {
            return "0"
        }
        
        return "\(String(format: "%0.*g", Int(log10(interval.abs)) + maximumFractionDigit + 1, interval))\(units[i])"
    }
}
