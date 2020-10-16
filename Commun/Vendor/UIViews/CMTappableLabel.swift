//
//  CMTappableLabel.swift
//  Commun
//
//  Created by Chung Tran on 6/22/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class CMTappableLabel: UILabel {

    var onCharacterTapped: ((_ label: UILabel, _ characterIndex: Int) -> Void)?

    func makeTappable() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(labelTapped))
        tapGesture.isEnabled = true
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    @objc func labelTapped(gesture: UITapGestureRecognizer) {

        // only detect taps in attributed text
        guard let attributedText = attributedText, gesture.state == .ended else {
            return
        }

        // Configure NSTextContainer
        let textContainer = NSTextContainer(size: bounds.size)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines

        // Configure NSLayoutManager and add the text container
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)

        // Configure NSTextStorage and apply the layout manager
        let textStorage = NSTextStorage(attributedString: attributedText)
        textStorage.addAttribute(NSAttributedString.Key.font, value: font!, range: NSRange(location: 0, length: attributedText.length))
        textStorage.addLayoutManager(layoutManager)

        // get the tapped character location
        let locationOfTouchInLabel = gesture.location(in: gesture.view)

        // account for text alignment and insets
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        var alignmentOffset: CGFloat!
        switch textAlignment {
        case .left, .natural, .justified:
            alignmentOffset = 0.0
        case .center:
            alignmentOffset = 0.5
        case .right:
            alignmentOffset = 1.0
        @unknown default:
            alignmentOffset = 0.0
        }
        let xOffset = ((bounds.size.width - textBoundingBox.size.width) * alignmentOffset) - textBoundingBox.origin.x
        let yOffset = ((bounds.size.height - textBoundingBox.size.height) * alignmentOffset) - textBoundingBox.origin.y
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - xOffset, y: locationOfTouchInLabel.y - yOffset)

        // figure out which character was tapped
        let characterTapped = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // figure out how many characters are in the string up to and including the line tapped
        let lineTapped = Int(ceil(locationOfTouchInLabel.y / font.lineHeight)) - 1
        let rightMostPointInLineTapped = CGPoint(x: bounds.size.width, y: font.lineHeight * CGFloat(lineTapped))
        let charsInLineTapped = layoutManager.characterIndex(for: rightMostPointInLineTapped, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        // ignore taps past the end of the current line
        if characterTapped < charsInLineTapped {
            onCharacterTapped?(self, characterTapped)
        }
    }
}
