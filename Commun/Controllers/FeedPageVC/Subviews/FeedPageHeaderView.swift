//
//  FeedPageHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 12/11/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class FeedPageHeaderView: MyTableHeaderView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    var postingViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Subviews
    lazy var postingView = UIView(backgroundColor: .appWhiteColor)
        lazy var avatarImageView = MyAvatarImageView(size: 40.0)
   
        lazy var openEditorWithPhotoImageView: UIImageView = {
        let iv = UIImageView(width: 24, height: 24, imageNamed: "editor-open-photo")
        iv.tintColor = .appGrayColor
        return iv
    }()
    
    lazy var promoBannerView: UIView = {
        let bannerView = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
        let imageView = UIImageView(imageNamed: "dankmeme_facebook")
        bannerView.addSubview(imageView)
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0))
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 355 / 244.84)
            .isActive = true
        
        let footerView = UIView(height: 64, backgroundColor: .appWhiteColor)
        bannerView.addSubview(footerView)
        footerView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        let label = UILabel.with(text: "just click".localized().uppercaseFirst, textSize: 15, weight: .medium, textColor: .appGrayColor, numberOfLines: 0)
        footerView.addSubview(label)
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0), excludingEdge: .trailing)
        
        footerView.addSubview(getButton)
        getButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        getButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        getButton.autoPinEdge(.leading, to: .trailing, of: label, withOffset: 16)
        return bannerView
    }()
    
    lazy var getButton = UIButton(width: .adaptive(width: 90), height: 34, label: "get".localized().uppercaseFirst, labelFont: .systemFont(ofSize: 12, weight: .semibold), backgroundColor: .appMainColor, textColor: .white, cornerRadius: 17)

    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        
        backgroundColor = .appLightGrayColor
        
        addSubview(postingView)
        postingView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        postingViewBottomConstraint = postingView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
        
        postingView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 0), excludingEdge: .trailing)
        
        avatarImageView
            .observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        let whatsNewLabel = UILabel.with(text: "what's new".localized().uppercaseFirst + "?", textSize: 17, weight: .medium, textColor: .appGrayColor)
        postingView.addSubview(whatsNewLabel)
        whatsNewLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        whatsNewLabel.autoPinEdge(toSuperviewEdge: .top)
        whatsNewLabel.autoPinEdge(toSuperviewEdge: .bottom)

        whatsNewLabel.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(postButtonDidTouch(_:)))
        whatsNewLabel.addGestureRecognizer(tapGesture)

        postingView.addSubview(openEditorWithPhotoImageView)
        openEditorWithPhotoImageView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        openEditorWithPhotoImageView.autoAlignAxis(toSuperviewMarginAxis: .horizontal)
        openEditorWithPhotoImageView.autoPinEdge(.leading, to: .trailing, of: whatsNewLabel, withOffset: 8)
        
        openEditorWithPhotoImageView.isUserInteractionEnabled = true
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(photoButtonDidTouch(_:)))
        openEditorWithPhotoImageView.addGestureRecognizer(tapGesture2)
    }
    
    func showPromoBanner() {
        postingViewBottomConstraint?.isActive = false
        promoBannerView.removeFromSuperview()
        addSubview(promoBannerView)
        promoBannerView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 10), excludingEdge: .top)
        
        postingViewBottomConstraint = promoBannerView.autoPinEdge(.top, to: .bottom, of: postingView, withOffset: 10)
    }
    
    func hidePromoBanner() {
        postingViewBottomConstraint?.isActive = false
        promoBannerView.removeFromSuperview()
        postingViewBottomConstraint = postingView.autoPinEdge(toSuperviewEdge: .bottom, withInset: 10)
    }
    
    // MARK: - Actions
    @objc func postButtonDidTouch(_ sender: Any) {
        openEditor()
    }
    
    @objc func photoButtonDidTouch(_ sender: Any) {
        openEditor { (editorVC) in
            editorVC.addImage()
        }
    }
    
    func openEditor(completion: ((BasicEditorVC) -> Void)? = nil) {
        let editorVC = BasicEditorVC(chooseCommunityAfterLoading: completion == nil)
        
        parentViewController?.present(editorVC, animated: true, completion: {
            completion?(editorVC)
        })
    }

}
