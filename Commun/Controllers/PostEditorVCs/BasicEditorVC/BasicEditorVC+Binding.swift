//
//  BasicEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func bindContentTextView() {
        super.bindContentTextView()
        
        // Parse link inside text
        contentTextView.rx.text
            .subscribe(onNext: { (text) in
                // ignore if one or more attachment existed
                if self._viewModel.attachments.value.count > 0 ||
                    self.link != nil
                {return}
                
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
                }
                else {
                    self.ignoredLinks.append(String(url))
                }
                
                self.link = String(url)
                
                // parseLink
                self.parseLink(self.link!)
            })
            .disposed(by: disposeBag)
    }
    
    func bindAttachments() {
        _viewModel.attachments.skip(1)
            .subscribe(onNext: {[weak self] (attachments) in
                guard let strongSelf = self else {return}
                
                // remove bottom constraint
                if let bottomConstraint = strongSelf.contentView.constraints.first(where: {$0.firstAttribute == .bottom && ($0.firstItem as? BasicEditorTextView) == strongSelf.contentTextView})
                {
                    strongSelf.contentView.removeConstraint(bottomConstraint)
                }
                
                strongSelf.attachmentsView.removeFromSuperview()
                strongSelf.attachmentsView.removeAllConstraints()
                
                // if no attachment is attached
                if attachments.count == 0 {
                    strongSelf.layoutBottomContentTextView()
                    return
                }
                
                // construct attachmentsView
                strongSelf.attachmentsView = AttachmentsView(forAutoLayout: ())
                strongSelf.attachmentsView.didRemoveAttachmentAtIndex = {[weak self] index in
                    if self?._viewModel.attachments.value[index].attributes?.url == self?.link {
                        self?.link = nil
                    }
                    self?._viewModel.removeAttachment(at: index)
                }
                strongSelf.contentView.addSubview(strongSelf.attachmentsView)
                strongSelf.attachmentsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
                strongSelf.attachmentsView.autoPinEdge(.top, to: .bottom, of: strongSelf.contentTextViewCountLabel, withOffset: 16)
                
                var height = strongSelf.view.bounds.width / 377 * 200
                if attachments.count > 2  {
                    height = height + height / 2
                }
                strongSelf.attachmentsView.autoSetDimension(.height, toSize: height)
                
                strongSelf.attachmentsView.setUp(with: attachments)
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
