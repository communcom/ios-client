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
            textView.insertText("\n\n")
            let mediaView = MediaView(frame: CGRect(x: 0, y: 8, width: frame.size.width, height: image.size.height * frame.size.width / image.size.width + 50))
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
                    strongSelf.textView.insertText("\n\n")
                    let mediaView = MediaView(frame: CGRect(x: 0, y: 8, width: strongSelf.frame.size.width, height: image.size.height * strongSelf.frame.size.width / image.size.width + 50))
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
}
