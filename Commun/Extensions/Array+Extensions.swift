//
//  Array.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfNotContains(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}

extension RangeReplaceableCollection where Element == ResponseAPIContentBlock {
    var shortAttributedString: NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = 21
        paragraph.maximumLineHeight = 21

        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .paragraphStyle: paragraph,
            .foregroundColor: UIColor.appBlackColor
        ]

        var texts = NSMutableAttributedString()
        var paragraphsTexts: [NSAttributedString] = []
        
        for (index, content) in enumerated() where content.type == "paragraph" {
            let attributedText = content.toAttributedString(currentAttributes: defaultAttributes, attachmentType: TextAttachment.self, shouldAddParagraphSeparator: false)
            // remove empty text
            let text = attributedText.string
           
            if text != "", text != " " {
                if index != 0 {
                    texts.append(NSAttributedString(string: "\n", attributes: defaultAttributes))
                }
                
                texts.append(attributedText)
                paragraphsTexts.append(attributedText)
            }
        }

        var moreTextAdded = false
        let moreText = NSAttributedString(string: "... \("see".localized().uppercaseFirst + " " + "more".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])

        if texts.length > 600 && !moreTextAdded {
            moreTextAdded = true
            texts = texts.attributedSubstring(from: NSRange(location: 0, length: 400)) as! NSMutableAttributedString
            texts.append(moreText)
        }

        if paragraphsTexts.count > 6 && !moreTextAdded {
            texts = NSMutableAttributedString()
            for (index, paragraph) in paragraphsTexts.enumerated() where index < 6 {
                texts.append(paragraph)
                texts.append(NSAttributedString(string: "\n", attributes: defaultAttributes))
            }
            texts.append(moreText)
        }
        
        return texts

//        if let content = post.content,
//            let firstSentence = content.first(where: {$0.type == "paragraph"}) {
//            let mutableAS = NSMutableAttributedString()
//            var attributedText = firstSentence
//                .toAttributedString(currentAttributes: defaultAttributes, attachmentType: TextAttachment.self)
//            if attributedText.length > 600 {
//                let moreText = NSAttributedString(string: "... \("See More".localized())", attributes: [.foregroundColor: UIColor.appMainColor, .font: UIFont.systemFont(ofSize: 14)])
//                attributedText = attributedText.attributedSubstring(from: NSRange(location: 0, length: 400))
//                mutableAS.append(moreText)
//            }
//            mutableAS.insert(attributedText, at: 0)
//
//            // check last charters a space
//            let spaceSymbols = "\n"
//            let components = mutableAS.components(separatedBy: spaceSymbols)
//            if let last = components.last, last.isEqual(to: NSAttributedString(string: "")) {
//                mutableAS.deleteCharacters(in: NSRange(location: mutableAS.length - spaceSymbols.count, length: spaceSymbols.count))
//            }
//
//            // remove paragraph separator
//            if mutableAS.string.starts(with: "\n\r") {
//                mutableAS.deleteCharacters(in: NSRange(location: 0, length: 2))
//            }
//
//            contentTextView.attributedText = mutableAS
//        } else {
//            centerConstraint.isActive = true
//        }
    }
}
