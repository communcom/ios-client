//
//  EditorPageTextView.swift
//  Commun
//
//  Created by Chung Tran on 8/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RTViewAttachment
import RxSwift
import RxCocoa
import SDWebImage

class EditorPageTextView: RTViewAttachmentTextView {
    // MARK: - Properties
    let bag = DisposeBag()
    var heightConstraint: NSLayoutConstraint!
    @IBInspectable var maxHeight: CGFloat = 0
    
    // options
    private let attachmentRightMargin: CGFloat = 8
    private let attachmentHeightForDescription: CGFloat = 80
    
    
    // MARK: - Class Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    func commonInit() {
        setUpExpandable()
        textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    }
    
    func setUpExpandable() {
        textView.isScrollEnabled = false
        textView.rx.text
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: {_ in
                var newFrame = self.textView.frame
                let width = newFrame.size.width
                let newSize = self.textView.sizeThatFits(CGSize(width:   width,
                                                       height:  CGFloat.greatestFiniteMagnitude))
                
                newFrame.size = CGSize(width: max(newSize.width, width), height: newSize.height)
                
                if (self.maxHeight > 0 && newFrame.size.height > self.maxHeight) {return}
                
                self.textView.frame = newFrame
                self.heightConstraint.constant = newSize.height
                self.layoutIfNeeded()
            })
            .disposed(by: bag)
        
        heightConstraint = constraints.first {$0.firstAttribute == .height}
    }
    
    // MARK: - Methods
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            let attachmentType = TextAttachment.AttachmentType.image(image: image, urlString: nil, description: description)
            let newWidth = frame.size.width - attachmentRightMargin
            let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentRightMargin))
            mediaView.showCloseButton = false
            mediaView.setUpWithAttachmentType(attachmentType)
            
            guard let textAttachment = TextAttachment(view: mediaView) else {return}
            textAttachment.type = attachmentType
            
            insert(textAttachment)
            textView.insertText("\n")
            
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            let textAttachment = TextAttachment(view: UIView())!
            textAttachment.type = .image(image: nil, urlString: urlString, description: description)
            textView.insertText(textAttachment.placeholderText)
            
            let manager = SDWebImageManager.shared()
            
            manager.imageDownloader?.downloadImage(with: url, completed: {[weak self] (image, data, error, _) in
                guard let strongSelf = self else {return}
                
                // current location of placeholder
                let location = strongSelf.textView
                    .nsRangeOfText(textAttachment.placeholderText).location
                
                guard location >= 0 else {return}
                
                // remove placeholder
                strongSelf.textView.removeText(textAttachment.placeholderText)
                
                // attach image
                if let image = image {
                    let attachmentType = TextAttachment.AttachmentType.image(image: image, urlString: urlString, description: description)
                    let newWidth = strongSelf.frame.size.width - strongSelf.attachmentRightMargin
                    let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + strongSelf.attachmentHeightForDescription))
                    mediaView.setUpWithAttachmentType(attachmentType)
                    mediaView.showCloseButton = false
                    
                    guard let textAttachment = TextAttachment(view: mediaView) else {return}
                    textAttachment.type = attachmentType
                    
                    strongSelf.insert(textAttachment)
                    strongSelf.textView.insertText("\n")
                } else {
                    strongSelf.parentViewController?.showErrorWithLocalizedMessage("could not load image".localized().uppercaseFirst + "with URL".localized() + " " + urlString)
                }
            })
        } else {
            parentViewController?.showGeneralError()
        }
    }
    
    func parseText(_ text: String?) {
        guard let text = text,
            let regex = try? NSRegularExpression(pattern: "\\[.*\\]\\(.*\\)", options: .caseInsensitive)
        else {return}
        // assign text
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes(textView.typingAttributes, range: NSMakeRange(0, attributedString.length))
        textView.attributedText = attributedString
        
        let imageDownloader = SDWebImageManager.shared().imageDownloader
        
        // find embeds
        for match in regex.matchedStrings(in: text) {
            
            let description = match.slicing(from: "[", to: "]")
            guard let urlString = match.slicing(from: "(", to: ")"),
                let url         = URL(string: urlString)
            else {continue}
            
            imageDownloader?.downloadImage(with: url, completed: { [weak self] (image, _, error, _) in
                guard let strongSelf = self else {return}
                // attach image
                if let image = image {
                    // get range of text
                    let textRange = strongSelf.textView.text.nsString.range(of: match)
                    let location = textRange.location
                    
                    guard location >= 0 else {return}
                    
                    let attachmentType = TextAttachment.AttachmentType.image(image: image, urlString: urlString, description: description)
                    let newWidth = strongSelf.frame.size.width - strongSelf.attachmentRightMargin
                    let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + strongSelf.attachmentHeightForDescription))
                    mediaView.setUpWithAttachmentType(attachmentType)
                    mediaView.showCloseButton = false
                    
                    guard let textAttachment = TextAttachment(view: mediaView) else {return}
                    textAttachment.type = attachmentType
                    
                    strongSelf.insert(textAttachment, at: UInt(location))
                    strongSelf.textView.removeText(match)
                }
            })
        }
    }
}
