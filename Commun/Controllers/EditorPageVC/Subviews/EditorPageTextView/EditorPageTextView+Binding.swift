//
//  EditorPageTextView+Binding.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorPageTextView {
    func bind() {
        rx.didChangeSelection
            .subscribe(onNext: {
                // get TextStyle at current selectedRange
                self.setCurrentTextStyle()
            })
            .disposed(by: bag)
        
        rx.didChange
            .subscribe(onNext: {
                self.resolveHashTags()
                
                // reset
                if self.attributedText.length == 0 {
                    self.typingAttributes = self.defaultTypingAttributes
                    self.setCurrentTextStyle()
                }
            })
            .disposed(by: bag)
    }
    
    private func setCurrentTextStyle() {
        var bold = false
        var italic = false
        var textColor = UIColor.black
        var urlString: String?
        
        let attrs = typingAttributes
        
        if let font = attrs[.font] as? UIFont {
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                bold = true
            }
            
            if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                italic = true
            }
        }
        
        if let color = attrs[.foregroundColor] as? UIColor,
            color != .black {
            textColor = color
        }
        
        if let link = attrs[.link] as? String {
            urlString = link
            textColor = .link
        }
        
        let textStyle = TextStyle(isBold: bold, isItalic: italic, textColor: textColor, urlString: urlString)
        
        self.currentTextStyle.accept(textStyle)
    }
}
