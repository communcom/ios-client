//
//  EditorPageTextView+Actions.swift
//  Commun
//
//  Created by Chung Tran on 9/3/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

extension EditorPageTextView {
    // MARK: - Methods
    private func attach(image: UIImage, urlString: String? = nil, description: String? = nil) {
        // Insert Attachment
        var attachment = TextAttachment()
        
        // add embed to attachment
        guard let embed = try? ResponseAPIFrameGetEmbed(blockAttributes: ContentBlockAttributes(url: urlString, description: description)) else {
            return
        }
        attachment.embed = embed
        attachment.embed?.type = "image"
        
        // save localImage to download later, if urlString not found
        if urlString == nil {
            attachment.localImage = image
        }
        
        // add image to attachment
        add(image, to: &attachment)
        
        // attachmentAS to add
        let attachmentAS = NSMutableAttributedString()
        
        // insert an separator at the beggining of attachment if not exists
        if selectedRange.location > 0,
            textStorage.attributedSubstring(from: NSMakeRange(selectedRange.location - 1, 1)).string != "\n" {
            attachmentAS.append(NSAttributedString.separator)
        }
        
        attachmentAS.append(NSAttributedString(attachment: attachment))
        attachmentAS.append(NSAttributedString.separator)
        attachmentAS.addAttributes(typingAttributes, range: NSMakeRange(0, attachmentAS.length))
        
        // replace
        textStorage.replaceCharacters(in: selectedRange, with: attachmentAS)
    }
    
    func addImage(_ image: UIImage? = nil, urlString: String? = nil, description: String? = nil) {
        
        // set image
        if let image = image {
            attach(image: image, urlString: urlString, description: description)
        } else if let urlString = urlString,
            let url = URL(string: urlString) {
            
            NetworkService.shared.downloadImage(url)
                .do(onSubscribe: {
                    self.parentViewController?.navigationController?
                        .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
                })
                .catchErrorJustReturn(UIImage(named: "image-not-available")!)
                .subscribe(
                    onSuccess: { [weak self] (image) in
                        guard let strongSelf = self else {return}
                        strongSelf.parentViewController?.navigationController?.hideHud()
                        strongSelf.attach(image: image, urlString: urlString, description: description)
                    },
                    onError: {[weak self] error in
                        self?.parentViewController?.navigationController?.hideHud()
                        self?.parentViewController?.showError(error)
                    }
                )
                .disposed(by: bag)
        } else {
            parentViewController?.showGeneralError()
        }
    }
    
    func parseText(_ string: String) {
        // Plain string
        var attributedText = NSAttributedString(string: string)
        
        // Parse data
        if let jsonData = string.data(using: .utf8),
            let block = try? JSONDecoder().decode(ContentBlock.self, from: jsonData) {
            attributedText = block.toAttributedString(currentAttributes: typingAttributes)
        }
        
        // Asign raw value first
        self.attributedText = attributedText
        
        // Parse medias
        parseContent()
            .do(onSubscribe: {
                self.parentViewController?.navigationController?
                    .showIndetermineHudWithMessage("loading".localized().uppercaseFirst)
            })
            .subscribe(onCompleted: { [weak self] in
                self?.parentViewController?.navigationController?.hideHud()
            }) { [weak self] (error) in
                self?.parentViewController?.navigationController?.showError(error)
            }
            .disposed(by: bag)
    }
    // TODO: Support pasting html
//    override func paste(_ sender: Any?) {
//        let pasteBoard = UIPasteboard.general
//        if let html = pasteBoard.items.last?["public.html"] as? String {
//            let htmlData = NSString(string: html).data(using: String.Encoding.unicode.rawValue)
//            let options = [NSAttributedString.DocumentReadingOptionKey.documentType:
//                NSAttributedString.DocumentType.html]
//            if let attributedString = try? NSMutableAttributedString(data: htmlData ?? Data(),
//                                                                  options: options,
//                                                                  documentAttributes: nil) {
//                attributedString.addAttribute(.font, value: defaultFont, range: NSMakeRange(0, attributedString.length))
//                textStorage.replaceCharacters(in: selectedRange, with: attributedString)
//                return
//            }
//        }
//
//        super.paste(sender)
//    }
}
