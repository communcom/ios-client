//
//  StringExtension.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/04/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CommonCrypto

extension String {
//    static var invisible: String {
//        return "\u{2063}"
//    }

    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return ceil(boundingBox.height)
    }
    
    func getTags() -> [String] {
        if let regex = try? NSRegularExpression(pattern: NSRegularExpression.tagRegexPattern, options: .caseInsensitive) {
            let string = self as NSString
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range)
                    .replacingOccurrences(of: "#", with: "")
            }
        }
        return []
    }
    
    var isLinkToMention: Bool {
        return self.matches("^\(NSRegularExpression.linkToMentionRegexPattern)$")
    }
    
    var isLinkToTag: Bool {
        return self.matches("^\(NSRegularExpression.linkToTagRegexPattern)$")
    }
    
    var isLink: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
    
    // MARK: - Telephone verification
    /// Fill missing number with dashes
    func fillWithDash(start: Int, offsetBy: Int) -> String {
        guard let substringStartIndex = self.index(startIndex, offsetBy: start, limitedBy: endIndex) else {
            return Array(0..<offsetBy).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        if let substringEndIndex = self.index(startIndex, offsetBy: start + offsetBy, limitedBy: endIndex) {
            return String(self[substringStartIndex ..< substringEndIndex])
        }
        
        var result = String(self[substringStartIndex...])
        
        if result.count < offsetBy {
            result += Array(0..<offsetBy-result.count).reduce("", {(result, _) -> String in
                return result + "_"}
            )
        }
        
        return result
    }
    
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    func slicing(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func toDouble() -> Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ru")
        let selfCopy = self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: ".", with: ",")

        return formatter.number(from: selfCopy)?.doubleValue ?? 0
    }
    
    var containsSpecialCharacter: Bool {
       let regex = ".*[^A-Za-z0-9].*"
       let testString = NSPredicate(format: "SELF MATCHES %@", regex)
       return testString.evaluate(with: self)
    }
    
    var containsNumber: Bool {
        let regex = ".*[0-9]+.*"
        let testString = NSPredicate(format: "SELF MATCHES %@", regex)
        return testString.evaluate(with: self)
    }
    
    func heightWithFont(font: UIFont = .systemFont(ofSize: 15), width: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = self
        label.sizeToFit()
        return label.frame.height
    }
    
    func removingLeadingSpaces() -> String {
        guard let index = firstIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[index...])
    }
    
    func removingTrailingSpaces() -> String {
        guard let index = lastIndex(where: { !CharacterSet(charactersIn: String($0)).isSubset(of: .whitespaces) }) else {
            return ""
        }
        return String(self[...index])
    }
}

extension StringProtocol {
    func index<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }
    func endIndex<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }
    func indices<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Index] {
        var indices: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                indices.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return indices
    }
    func ranges<S: StringProtocol>(of string: S, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...]
                .range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
