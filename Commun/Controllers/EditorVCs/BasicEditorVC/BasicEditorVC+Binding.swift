//
//  BasicEditorVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension BasicEditorVC {
    func bindAttachments() {
        _viewModel.attachments.skip(1)
            .subscribe(onNext: {[unowned self] (attachments) in
                // remove bottom constraint
                guard let bottomConstraint = self.contentView.constraints.first(where: {$0.firstAttribute == .bottom && ($0.firstItem as? BasicEditorTextView) == self.contentTextView})
                    else {return}
                self.contentTextView.removeConstraint(bottomConstraint)
                
                self.attachmentsView.removeFromSuperview()
                self.attachmentsView.removeAllConstraints()
                
                // if no attachment is attached
                if attachments.count == 0 {
                    self.layoutBottomContentTextView()
                    return
                }
                
                // construct attachmentsView
                self.attachmentsView = AttachmentsView(forAutoLayout: ())
                self.attachmentsView.didRemoveAttachmentAtIndex = { index in
                    self._viewModel.removeAttachment(at: index)
                }
                self.contentView.addSubview(self.attachmentsView)
                self.attachmentsView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .top)
                self.attachmentsView.autoPinEdge(.top, to: .bottom, of: self.contentTextViewCountLabel, withOffset: 16)
                
                self.attachmentsView.setUp(with: attachments)
            })
            .disposed(by: disposeBag)
    }
}
