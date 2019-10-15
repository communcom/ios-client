//
//  BasicEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    override func bind() {
        super.bind()
        
        bindAttachments()
    }
    
    func bindAttachments() {
        _viewModel.attachments.skip(1)
            .subscribe(onNext: {[unowned self] (attachments) in
                // remove bottom constraint
                if let bottomConstraint = self.contentView.constraints.first(where: {$0.firstAttribute == .bottom && ($0.firstItem as? BasicEditorTextView) == self.contentTextView})
                {
                    self.contentView.removeConstraint(bottomConstraint)
                }
                
                self.attachmentsView.removeFromSuperview()
                self.attachmentsView.removeAllConstraints()
                
                // if no attachment is attached
                if attachments.count == 0 {
                    self.layoutBottomContentTextView()
                    return
                }
                
                // construct attachmentsView
                self.attachmentsView = AttachmentsView(forAutoLayout: ())
                self.attachmentsView.didRemoveAttachmentAtIndex = {[weak self] index in
                    self?._viewModel.removeAttachment(at: index)
                }
                self.contentView.addSubview(self.attachmentsView)
                self.attachmentsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
                self.attachmentsView.autoPinEdge(.top, to: .bottom, of: self.contentTextViewCountLabel, withOffset: 16)
                
                var height = self.view.bounds.width / 377 * 200
                if attachments.count > 2  {
                    height = height + height / 2
                }
                self.attachmentsView.autoSetDimension(.height, toSize: height)
                
                self.attachmentsView.setUp(with: attachments)
            })
            .disposed(by: disposeBag)
    }
}
