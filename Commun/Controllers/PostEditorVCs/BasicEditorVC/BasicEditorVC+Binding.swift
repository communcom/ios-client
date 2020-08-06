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
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (text) in
                if text == self.contentTextView.originalAttributedString?.string {return}
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
            .do(onNext: { (attachment) in
                if attachment != nil {
                    DispatchQueue(label: "archiving").async {
                        self.saveDraft()
                    }
                }
            })
            .subscribe(onNext: { [weak self] (attachment) in
                self?.attachmentView.removeSubviews()
                
                guard let attachment = attachment,
                    let attributes = attachment.attributes,
                    let type = attributes.type
                else {
                    return
                }
                
                let attachmentView = AttachmentView(forAutoLayout: ())
                attachmentView.attachment = attachment
                attachmentView.tag = 0
                attachmentView.delegate = self
                self?.attachmentView.addSubview(attachmentView)
                attachmentView.autoPinEdgesToSuperviewEdges()
                
                if let url = attributes.url {
                    attachmentView.setUp(block: ResponseAPIContentBlock(id: 0, type: type, attributes: attributes, content: ResponseAPIContentBlockContent.string(url)))
                } else {
                    attachmentView.setUp(image: attachment.localImage, url: attachment.attributes?.url, description: attachment.attributes?.title ?? attachment.attributes?.description)
                    attachmentView.autoSetDimension(.height, toSize: attachment.size?.height ?? 300)
                    attachmentView.expandButton.isHidden = true
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    override func bindCommunity() {
        super.bindCommunity()
        viewModel.community
            .filter {$0 != nil}
            .subscribe(onNext: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.contentTextView.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)
    }
}
