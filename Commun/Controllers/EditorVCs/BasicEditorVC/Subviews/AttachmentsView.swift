//
//  AttachmentsView.swift
//  Commun
//
//  Created by Chung Tran on 10/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class AttachmentsView: UIView {
    struct Attachment: Equatable {
        var originalImage: UIImage?
        var urlString: String?
        var description: String?
        
        static func == (lhs: Attachment, rhs: Attachment) -> Bool {
            if lhs.originalImage == rhs.originalImage {return true}
            if lhs.urlString == rhs.urlString {return true}
            return false
        }
    }
    
    var imageViews: [UIImageView]?
    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        commonInit()
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    func commonInit() {
//
//    }
    
    var didRemoveAttachmentAtIndex: ((Int)->Void)?
    
    @objc func close(sender: UIButton) {
        let index = sender.tag
        didRemoveAttachmentAtIndex?(index)
    }
    
    private func imageViewWithCloseButton(index: Int) -> UIImageView {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.isUserInteractionEnabled = true
        let closeButton = UIButton.circleGray(imageName: "close-x")
        closeButton.tag = index
        imageView.addSubview(closeButton)
        closeButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 16)
        closeButton.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
        return imageView
    }
    
    func setUp(with attachments: [Attachment]) {
        // if 1 attachment attached
//        if attachments.count == 1 {
            let attachment = attachments[0]
            let imageView = imageViewWithCloseButton(index: 0)
            addSubview(imageView)
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
//        }
                            
        // TODO: support more than 1 images
//        else {
//            let numberOfImagesInARow = 3
//            let padding = 4
//            for (index, attachment) in attachments.enumerated() {
//                let imageView = UIImageView(forAutoLayout: ())
//                self.attachmentsView?.addSubview(imageView)
//
//                imageView.widthAnchor.constraint(equalTo: self.attachmentsView!.widthAnchor, multiplier: CGFloat(1/numberOfImagesInARow))
//                    .isActive = true
//                imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
//                    .isActive = true
//
//                if index < numberOfImagesInARow {
//                    imageView.autoPinEdge(toSuperviewEdge: .top)
//                }
//            }
//        }
    }
}
