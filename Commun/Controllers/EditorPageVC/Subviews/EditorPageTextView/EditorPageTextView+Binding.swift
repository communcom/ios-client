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
        // get TextStyle at current selectedRange
        rx.didChangeSelection
            .subscribe(onNext: {
                var bold = false
                var italic = false
                var textColor = UIColor.black
                var urlString: String?
                
                let attrs = self.typingAttributes
                
                if let font = attrs[.font] as? UIFont {
                    if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                        bold = true
                    }
                    
                    if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                        italic = true
                    }
                }
                
                if let color = attrs[.foregroundColor] as? UIColor {
                    textColor = color
                }
                
                if let link = attrs[.link] as? String {
                    urlString = link
                    textColor = .link
                }
                
                let textStyle = TextStyle(isBold: bold, isItalic: italic, textColor: textColor, urlString: urlString)
                
                self.currentTextStyle.onNext(textStyle)
                
            })
            .disposed(by: bag)
    }
}
