//
//  EditorPageTextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SDWebImage
import CyberSwift

class EditorPageTextView: ExpandableTextView {
    // MARK: - Nested types
    struct TextStyle {
        var isBold = false
        var isItalic = false
        var textColor: UIColor = .black
        var urlString: String?
    }
    
    // MARK: - Properties
    let bag = DisposeBag()
    var currentTextStyle = PublishSubject<TextStyle>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bind()
    }
    
    func bind() {
        // get TextStyle at current selectedRange
        rx.didChangeSelection
            .subscribe(onNext: {
                var bold = false
                var italic = false
                var textColor = UIColor.black
                var urlString: String?
                
                var detectRange = self.selectedRange
                
                if detectRange.length == 0 {
                    if detectRange.location == 0,
                        self.attributedText.length > 0 {
                        detectRange.length = 1
                    }
                    else {
                        detectRange.location -= 1
                        detectRange.length = 1
                    }
                }
                
                let string = self.attributedText.attributedSubstring(from: detectRange)
                
                let attrs = string.attributes
                
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
                }
                
                let textStyle = TextStyle(isBold: bold, isItalic: italic, textColor: textColor, urlString: urlString)
                
                self.currentTextStyle.onNext(textStyle)
                
            })
            .disposed(by: bag)
    }
}
