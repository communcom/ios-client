//
//  PostHeaderTextView.swift
//  Commun
//
//  Created by Chung Tran on 10/16/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import SubviewAttachingTextView

class PostHeaderTextView: MySubviewAttachingTextView {
    static let attachmentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    lazy var attachmentSize: CGSize = {
        let width = size.width
        return CGSize(width: width, height: 238)
    }()
    let defaultFont = UIFont.systemFont(ofSize: 17)
    
    var defaultAttributes: [NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.paragraphSpacing = 8
        return [
            .font: defaultFont,
            .paragraphStyle: paragraphStyle
        ]
    }
    
    override func commonInit() {
        super.commonInit()
        textContainerInset = UIEdgeInsets(
            top: 0,
            left: PostHeaderTextView.attachmentInset.left,
            bottom: 0,
            right: PostHeaderTextView.attachmentInset.right)
        textContainer.lineFragmentPadding = 0;
    }
}

open class MySubviewAttachingTextView: UITextView {

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    private let attachmentBehavior = MySubviewAttachingTextViewBehavior()

    func commonInit() {
        // Connect the attachment behavior
        self.attachmentBehavior.textView = self
        self.layoutManager.delegate = self.attachmentBehavior
        self.textStorage.delegate = self.attachmentBehavior
    }

    open override var textContainerInset: UIEdgeInsets {
        didSet {
            // Text container insets are used to convert coordinates between the text container and text view, so a change to these insets must trigger a layout update
            self.attachmentBehavior.layoutAttachedSubviews()
        }
    }

}

class MySubviewAttachingTextViewBehavior: SubviewAttachingTextViewBehavior {
    override func layoutAttachedSubviews() {
        guard let textView = self.textView else {
            return
        }

        let layoutManager = textView.layoutManager
        let scaleFactor = textView.window?.screen.scale ?? UIScreen.main.scale

        // For each attached subview, find its associated attachment and position it according to its text layout
        let attachmentRanges = textView.textStorage.subviewAttachmentRanges
        for (attachment, range) in attachmentRanges {
            guard let view = self.attachedViews.object(forKey: attachment.viewProvider) else {
                // A view for this provider is not attached yet??
                continue
            }
            guard view.superview === textView else {
                // Skip views which are not inside the text view for some reason
                continue
            }
            guard let attachmentRect = SubviewAttachingTextViewBehavior.boundingRect(forAttachmentCharacterAt: range.location, layoutManager: layoutManager) else {
                // Can't determine the rectangle for the attachment: just hide it
                view.isHidden = true
                continue
            }

            let integralRect = CGRect(origin: attachmentRect.origin.integral(withScaleFactor: scaleFactor),
                                      size: attachmentRect.size)
            
            UIView.performWithoutAnimation {
                view.frame = integralRect
                view.isHidden = false
            }
        }
    }
}
