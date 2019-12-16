//
//  BasicEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension BasicEditorVC {
    override func bindContentTextView() {
        super.bindContentTextView()
        
        // Parse link inside text
        contentTextView.rx.text
            .filter {_ in !self.isParsingPost}
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                // ignore if one or more attachment existed
                if self._viewModel.attachment.value != nil ||
                    self.link != nil {return}
                
                // get link in text
                guard let text = text,
                    !text.isEmpty
                else {
                    self.ignoredLinks = []
                    return
                }
                
                // detect link
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))

                if matches.count < 1 {return}
                let match = matches[0]
                guard let range = Range(match.range, in: text) else { return }
                let url = self.contentTextView.text[range]
                
                // check ignored
                if self.ignoredLinks.contains(String(url)) {
                    return
                } else {
                    self.ignoredLinks.append(String(url))
                }
                
                self.link = String(url)
                
                // parseLink
                self.parseLink(self.link!)
            })
            .disposed(by: disposeBag)
    }
    
    func bindAttachments() {
        _viewModel.attachment
            .subscribe(onNext: { [weak self] (attachment) in
                guard let attachment = attachment,
                    let attributes = attachment.attributes,
                    let type = attributes.type
                else {
                    self?.attachmentView.removeSubviews()
                    self?.attachmentView.autoSetDimension(.height, toSize: 300)
                    self?.attachmentView.isHidden = true
                    return
                }
                self?.attachmentView.removeSubviews()
                self?.attachmentView.heightConstraint?.isActive = false
                self?.attachmentView.isHidden = false
                
                let attachmentView = AttachmentView(forAutoLayout: ())
                attachmentView.attachment = attachment
                attachmentView.isUserInteractionEnabled = true
                attachmentView.tag = 0
                attachmentView.delegate = self
                self?.attachmentView.addSubview(attachmentView)
                attachmentView.autoPinEdgesToSuperviewEdges()
                
                if let url = attributes.url {
                    let embedView = EmbedView(content: ResponseAPIContentBlock(id: 0, type: type, attributes: attributes, content: ResponseAPIContentBlockContent.string(url)))
                    attachmentView.addSubview(embedView)
                    embedView.autoPinEdgesToSuperviewEdges()
                    attachmentView.bringSubviewToFront(attachmentView.closeButton)
                    attachmentView.expandButton.isHidden = true
                } else {
                    attachmentView.setUp(image: attachment.localImage, url: attachment.attributes?.url, description: attachment.attributes?.title ?? attachment.attributes?.description)
                    attachmentView.autoSetDimension(.height, toSize: 200)
                    attachmentView.expandButton.isHidden = false
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    override func bindCommunity() {
        super.bindCommunity()
        viewModel.community
            .filter {$0 != nil}
            .subscribe(onNext: { _ in
                self.contentTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
    }
}
