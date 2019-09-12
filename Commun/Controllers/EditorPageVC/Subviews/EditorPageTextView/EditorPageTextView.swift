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
    let defaultFont = UIFont.systemFont(ofSize: 17)
    lazy var defaultTypingAttributes: [NSAttributedString.Key: Any] = [.font: defaultFont]
    
    var currentTextStyle = BehaviorRelay<TextStyle>(value: TextStyle(isBold: false, isItalic: false, textColor: .black, urlString: nil))
    
    var originalAttributedString: NSAttributedString?
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // set default attributes
        typingAttributes = [.font: defaultFont]
        
        // bind actions
        bind()
    }
    
    // MARK: - Computed properties
    var selectedAString: NSAttributedString {
        return attributedText.attributedSubstring(from: selectedRange)
    }
}
