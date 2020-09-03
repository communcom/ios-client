//
//  BasicPostTextView.swift
//  Commun
//
//  Created by Chung Tran on 9/3/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import UIKit

class BasicPostCellTextView: UITextView {
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        textContainerInset = UIEdgeInsets.zero
        self.textContainer.lineFragmentPadding = 0
        font = .systemFont(ofSize: 14)
        dataDetectorTypes = .link
        backgroundColor = .clear
        isEditable = false
        isSelectable = false
        
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(contentTextViewDidTouch(_:))))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        urlString(at: point) != nil
    }
    
    func urlString(at point: CGPoint) -> String? {
        var location = point
        location.x -= textContainerInset.left
        location.y -= textContainerInset.top
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < textStorage.length {
            // print the character index
//            print("character index: \(characterIndex)")

            // print the character at the index
//            let myRange = NSRange(location: characterIndex, length: 1)
//            let substring = (attributedText.string as NSString).substring(with: myRange)
//            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeName = NSAttributedString.Key.link
            let attributeValue = attributedText?.attribute(attributeName, at: characterIndex, effectiveRange: nil)
            return attributeValue as? String
        }
        return nil
    }
    
    @objc func contentTextViewDidTouch(_ gesture: UITapGestureRecognizer) {
        if let string = urlString(at: gesture.location(in: self)),
            let url = URL(string: string)
        {
            parentViewController?.handleUrl(url: url)
        }
    }
}
