//
//  Date.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
import Foundation

extension Date {
    static func from(string: String) -> Date {
        let formatter = DateFormatter()
        
        // Format 1
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let parsedDate = formatter.date(from: string) {
            return parsedDate
        }
        
        // Format 2
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SSSZ"
        if let parsedDate = formatter.date(from: string) {
            return parsedDate
        }
        
        // Couldn't parsed with any format. Just get the date
        let splitedDate = string.components(separatedBy: "T")
        if splitedDate.count > 0 {
            formatter.dateFormat = "yyyy-MM-dd"
            if let parsedDate = formatter.date(from: splitedDate[0]) {
                return parsedDate
            }
        }
        
        // Nothing worked!
        return Date()
    }
    
    static func timeAgo(string: String) -> String {
        return Date.from(string: string).timeAgoSinceDate()
    }

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_EN")

        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            dateFormatter.dateFormat = "yyyy MMM dd"
            return dateFormatter.string(from: fromDate)
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            dateFormatter.dateFormat = "MMM dd"
            return dateFormatter.string(from: fromDate)
        }

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return "\(interval)" + "d ago"
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {

            return "\(interval)" + "h ago"
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return "\(interval)" + "m ago"
        }

        return "a moment ago"
    }
}
