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
                print(self.contentView.constraints)
                
                // remove bottom constraint
                guard let bottomConstraint = self.contentView.constraints.first(where: {$0.firstAttribute == .bottom && ($0.firstItem as? BasicEditorTextView) == self.contentTextView})
                    else {return}
                self.contentTextView.removeConstraint(bottomConstraint)
                
                // if no attachment is attached
                if attachments.count == 0 {
                    self.attachmentsView?.removeFromSuperview()
                    self.layoutBottomContentTextView()
                    return
                }
                
                // construct attachmentsView
                self.attachmentsView = UIView(forAutoLayout: ())
                self.contentView.addSubview(self.attachmentsView!)
                self.attachmentsView?.autoPinEdge(toSuperviewEdge: .leading)
                self.attachmentsView?.autoPinEdge(toSuperviewEdge: .trailing)
                self.attachmentsView?.autoPinEdge(.top, to: .top, of: self.contentTextViewCountLabel, withOffset: 16)
                
                // if 1 attachment attached
//                if attachments.count == 1 {
                    let attachment = attachments[0]
                    let imageView = UIImageView(forAutoLayout: ())
                    self.attachmentsView!.addSubview(imageView)
                    imageView.autoPinEdgesToSuperviewEdges()
                
                    let heightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 2/3)
                
                    heightConstraint.isActive = true
                    if let image = attachment.originalImage {
                        
                        imageView.image = image
                    }
                    else {
                        imageView.sd_setImageCachedError(with: URL(string: attachment.urlString!)) { (error, image) in
                            if let image = image {
                                heightConstraint.isActive = false
                                let fixedHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: image.size.height / image.size.width)
                                fixedHeightConstraint.isActive = true
                            }
                        }
                    }
//                }
                    
                // TODO: support more than 1 images
//                else {
//                    let numberOfImagesInARow = 3
//                    let padding = 4
//                    for (index, attachment) in attachments.enumerated() {
//                        let imageView = UIImageView(forAutoLayout: ())
//                        self.attachmentsView?.addSubview(imageView)
//
//                        imageView.widthAnchor.constraint(equalTo: self.attachmentsView!.widthAnchor, multiplier: CGFloat(1/numberOfImagesInARow))
//                            .isActive = true
//                        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
//                            .isActive = true
//
//                        if index < numberOfImagesInARow {
//                            imageView.autoPinEdge(toSuperviewEdge: .top)
//                        }
//                    }
//                }
            })
            .disposed(by: disposeBag)
    }
}
