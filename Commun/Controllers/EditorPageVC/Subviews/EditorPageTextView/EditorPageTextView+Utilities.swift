//
//  EditorPageTextView+Utilities.swift
//  Commun
//
//  Created by Chung Tran on 9/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

extension EditorPageTextView {
    // MARK: - typingAttributes modification
    func setCurrentTextStyle() {
        var textStyle = TextStyle.default
        
        // Get attributes from typingAttributes
        let attrs = typingAttributes
        if let font = attrs[.font] as? UIFont {
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) {
                textStyle = textStyle.setting(isBool: true)
            }
            
            if font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                textStyle = textStyle.setting(isItalic: true)
            }
        }
        
        if let color = attrs[.foregroundColor] as? UIColor,
            color != .black {
            textStyle = textStyle.setting(textColor: color)
        }
        
        if let link = attrs[.link] as? String {
            textStyle = textStyle.setting(textColor: .link, urlString: link)
        }
        
        // Check if textStyle is mixed
        textStyle = textStyle.setting(isMixed: selectedRangeHasDifferentTextStyle)
        
        // Notify
        self.currentTextStyle.accept(textStyle)
    }
    
    /// if text in selectedRange has different style
    var selectedRangeHasDifferentTextStyle: Bool {
        if selectedRange.length == 0 {return false}
        var isMixed = false
        textStorage.enumerateAttributes(in: selectedRange, options: []) { (attrs, range, stop) in
            if range != selectedRange {
                isMixed = true
                stop.pointee = true
            }
        }
        return isMixed
    }
    
    // MARK: - Attachment helper
    func add(_ image: UIImage, to attachment: inout TextAttachment) {
        let attachmentRightMargin: CGFloat = 10
        let attachmentHeightForDescription: CGFloat = MediaView.descriptionDefaultHeight
        
        // setup view
        let newWidth = frame.size.width - attachmentRightMargin - textContainerInset.left - textContainerInset.right
        let mediaView = MediaView(frame: CGRect(x: 0, y: 0, width: newWidth, height: image.size.height * newWidth / image.size.width + attachmentHeightForDescription))
        mediaView.showCloseButton = false
        mediaView.setUp(image: image, url: attachment.embed?.url, description: attachment.embed?.title ?? attachment.embed?.description)
        addSubview(mediaView)
        
        attachment.view = mediaView
        mediaView.removeFromSuperview()
    }
    
    func canAddAttachment(_ attachment: TextAttachment) -> Bool {
        var embedCount = 1
        var videoCount = attachment.embed?.type == "video" ? 1 : 0
        
        // Count attachments
        textStorage.enumerateAttribute(.attachment, in: NSMakeRange(0, textStorage.length), options: []) { (attr, range, stop) in
            if let attr = attr as? TextAttachment {
                embedCount += 1
                if attr.embed?.type == "video"
                {
                    videoCount += 1
                }
            }
        }
        
        return embedCount <= embedsLimit && videoCount <= videosLimit
    }
    
    func addAttachmentAtSelectedRange(_ attachment: TextAttachment) {
        // check if can add attachment
        if !canAddAttachment(attachment) {
            parentViewController?.showErrorWithMessage("can not add more than".localized().uppercaseFirst + " " + "\(embedsLimit)" + " " + "attachments".localized() + " " + "and" + " " + "\(videosLimit)" + " " + "videos".localized())
            return
        }
        
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
        selectedRange = NSMakeRange(selectedRange.location + attachmentAS.length, 0)
    }
    
    func replaceCharacters(in range: NSRange, with attachment: TextAttachment) {
        let attachmentAS = NSAttributedString(attachment: attachment)
        textStorage.replaceCharacters(in: range, with: attachmentAS)
        textStorage.addAttributes(typingAttributes, range: NSMakeRange(range.location, 1))
    }
    
    func getContentBlock() -> Single<ContentBlock> {
        // spend id = 1 for PostBlock, so id starts from 1
        var id: UInt = 1
        
        // child blocks of post block
        var contentBlocks = [Single<ContentBlock>]()
        
        // get AS, which was separated by the Escaping String
        var attachmentRanges = [NSRange]()
        textStorage.enumerateAttributes(in: NSMakeRange(0, textStorage.length), options: []) { (attrs, range, bool) in
            // parse attachments
            if let _ = attrs[.attachment] as? TextAttachment {
                attachmentRanges.append(range)
            }
        }
        
        // parse attributed string
        var start = 0
        
        for range in attachmentRanges {
            // add text from start to attachment's location
            if range.location - start > 0 {
                let end = range.location - 1
                let rangeForText = NSMakeRange(start, end - start + 1)
                let subAS = textStorage.attributedSubstring(from: rangeForText)
                let components = subAS.components(separatedBy: "\n")
                for component in components {
                    if let block = component.toParagraphContentBlock(id: &id) {
                        contentBlocks.append(.just(block))
                    }
                }
            }
            
            // add attachment
            if let attachment = textStorage.attributes(at: range.location, effectiveRange: nil)[.attachment] as? TextAttachment,
                let single = attachment.toSingleContentBlock(id: &id)
            {
                contentBlocks.append(single)
            }
            
            // new start
            start = range.location + 1
            if start >= textStorage.length {
                break
            }
        }
        
        // add last
        if start < textStorage.length {
            let lastRange = NSMakeRange(start, textStorage.length - start)
            let subAS = textStorage.attributedSubstring(from: lastRange)
            let components = subAS.components(separatedBy: "\n")
            for component in components {
                if let block = component.toParagraphContentBlock(id: &id) {
                    contentBlocks.append(.just(block))
                }
            }
        }
        
        
        return Single.zip(contentBlocks)
            .map {contentBlocks -> ContentBlock in
                return ContentBlock(
                    id: 1,
                    type: "post",
                    attributes: ContentBlockAttributes(),
                    content: .array(contentBlocks))
        }
    }
    
    // MARK: - contextMenu modification
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) {
            let pasteBoard = UIPasteboard.general
            if pasteBoard.items.last?["attachment"] != nil { return true }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func paste(_ sender: Any?) {
        let pasteBoard = UIPasteboard.general
        
        // Paste attachment
        if let data = pasteBoard.items.last?["attachment"] as? Data,
            let attachment = try? JSONDecoder().decode(TextAttachment.self, from: data)
        {
            addAttachmentAtSelectedRange(attachment)
            return
        }
        
        // TODO: Paste html
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

        super.paste(sender)
    }
    
    // MARK: - Draft
    func saveDraft(completion: (()->Void)? = nil) {
        parentViewController?
            .showIndetermineHudWithMessage("archiving".localized().uppercaseFirst)
        var draft = [Data]()
        let aText = self.attributedText!
        DispatchQueue(label: "archiving").async {
            aText.enumerateAttributes(in: NSMakeRange(0, aText.length), options: []) { (attributes, range, stop) in
                if let attachment = attributes[.attachment] as? TextAttachment {
                    if let data = try? JSONEncoder().encode(attachment) {
                        draft.append(data)
                    }
                    return
                }
                if let data = try? aText.data(from: range, documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])
                {
                    draft.append(data)
                }
            }
            if let data = try? JSONEncoder().encode(draft) {
                UserDefaults.standard.set(data, forKey: self.draftKey)
            }
            DispatchQueue.main.async {
                self.parentViewController?.hideHud()
                completion?()
            }
        }
    }
    
    func getDraft(completion: (()->Void)? = nil) {
        // show hud
        self.parentViewController?
            .showIndetermineHudWithMessage("retrieving draft".localized().uppercaseFirst)
        
        // retrieve draft on another thread
        DispatchQueue(label: "pasting").async {
            guard let data = UserDefaults.standard.data(forKey: self.draftKey),
                let draft = try? JSONDecoder().decode([Data].self, from: data) else {
                    DispatchQueue.main.async {
                        self.parentViewController?.hideHud()
                    }
                    return
            }
            
            let mutableAS = NSMutableAttributedString()
            for data in draft {
                var skip = false
                DispatchQueue.main.sync {
                    if let attachment = try? JSONDecoder().decode(TextAttachment.self, from: data)
                    {
                        let attachmentAS = NSAttributedString(attachment: attachment)
                        mutableAS.append(attachmentAS)
                        skip = true
                    }
                }
                
                if skip {continue}
                
                if let aStr = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.rtfd], documentAttributes: nil)
                {
                    mutableAS.append(aStr)
                }
            }
            
            DispatchQueue.main.async {
                // Has to modify font back to systemFont because of illegal font in data
                mutableAS.enumerateAttributes(in: NSMakeRange(0, mutableAS.length), options: []) { (attributes, range, stop) in
                    guard let currentFont = attributes[.font] as? UIFont else {return}
                    var font = self.defaultFont
                    let symbolicTraits = currentFont.fontDescriptor.symbolicTraits
                    font = UIFont(
                        descriptor: font.fontDescriptor.withSymbolicTraits(symbolicTraits)!,
                        size: 17)
                    mutableAS.addAttribute(.font, value: font, range: range)
                }
                
                // set attributedText
                self.attributedText = mutableAS
                
                // hide hud
                self.parentViewController?
                    .hideHud()
                
                completion?()
            }
        }
    }
    
    func removeDraft() {
        UserDefaults.standard.removeObject(forKey: self.draftKey)
    }
    
    var hasDraft: Bool {
        return UserDefaults.standard.dictionaryRepresentation().keys.contains(draftKey)
    }
}
