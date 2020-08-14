//
//  Date.swift
//  Commun
//
//  Created by Chung Tran on 15/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
import Foundation
import CyberSwift
import Localize_Swift

extension DateFormatter {
    static var `default`: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Localize.currentLanguage())
        return dateFormatter
    }
}

extension Date {
    
    static func timeAgo(string: String) -> String {
        return Date.from(string: string).timeAgoSinceDate()
    }
    
    func intervalToDate(date: Date = Date()) -> String {
        // From Time
        let fromDate = self

        // To Time
        let toDate = date

        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return String(format: NSLocalizedString("%d day", comment: ""), interval)
        }

        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return String(format: NSLocalizedString("%d hour", comment: ""), interval)
        }

        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return String(format: NSLocalizedString("%d minute", comment: ""), interval)
        }

        return "a moment".localized()
    }

    func timeAgoSinceDate() -> String {
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: self, to: Date()).year, interval > 0  {
            let formatter = DateFormatter.default
            formatter.dateFormat = "yyyy MMM dd"
            return formatter.string(from: self)
        }

        // Month
        if let interval = Calendar.current.dateComponents([.month], from: self, to: Date()).month, interval > 0  {
            let formatter = DateFormatter.default
            formatter.dateFormat = "MMM dd"
            return formatter.string(from: self)
        }
        
        let intervalString = intervalToDate()
        if intervalString == "a moment" {
            return "a moment ago".localized()
        }
        return intervalString + " " + "ago".localized()
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
