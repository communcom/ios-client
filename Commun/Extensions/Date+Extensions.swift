//
//  Date.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
import Foundation
import CyberSwift

extension Date {
    
    static func timeAgo(string: String) -> String {
        return Date.from(string: string).timeAgoSinceDate()
    }

    func timeAgoSinceDate() -> String {

        // From Time
        let fromDate = self

        // To Time
        let toDate = Date()

        let dateFormatter = DateFormatter()

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
            return String(format: NSLocalizedString("%d day", comment: ""), interval) + " " + "ago".localized()
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return String(format: NSLocalizedString("%d hour", comment: ""), interval) + " " + "ago".localized()
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return String(format: NSLocalizedString("%d month", comment: ""), interval) + " " + "ago".localized()
        }

        return "a moment ago".localized()
    }
    
    func dayDifference(from interval: TimeInterval) -> String
    {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        let startOfNow = calendar.startOfDay(for: Date())
        let startOfTimeStamp = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp)
        let day = components.day!
        if abs(day) < 2 {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        } else if day > 1 {
            return "In \(day) days"
        } else {
            return "\(-day) days ago"
        }
    }
}
