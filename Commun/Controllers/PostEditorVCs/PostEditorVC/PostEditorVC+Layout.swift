//
//  PostEditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostEditorVC {
    @objc func layoutTopContentTextView() {
        fatalError("Must override")
    }
    
    @objc func layoutBottomContentTextView() {
        fatalError("Must override this method")
    }
    
    override func layoutContentView() {
        // community
        contentView.addSubview(communityView)
        communityView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        communityView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCommunityDidTouch))
        communityView.addGestureRecognizer(tap)
        
        communityView.addSubview(communityAvatarImage)
        communityAvatarImage.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        

        let youWillPostIn = UILabel.descriptionLabel("you will post in".localized().uppercaseFirst)
        communityView.addSubview(youWillPostIn)
        youWillPostIn.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
        youWillPostIn.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        
        communityView.addSubview(communityNameLabel)
        communityNameLabel.autoPinEdge(toSuperviewEdge: .bottom, withInset: 18)
        communityNameLabel.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        
        let dropdownButton = UIButton.circleGray(imageName: "drop-down")
        communityView.addSubview(dropdownButton)
        dropdownButton.isUserInteractionEnabled = false
        dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        dropdownButton.autoAlignAxis(toSuperviewAxis: .horizontal)
        dropdownButton.leadingAnchor.constraint(greaterThanOrEqualTo: communityNameLabel.trailingAnchor, constant: 8)
            .isActive = true
        
        // textView
        contentView.addSubview(contentTextView)
        
        layoutTopContentTextView()
        layoutContentTextView()
        layoutBottomContentTextView()
    }
    
    func layoutContentTextView() {
        contentTextView.autoPinEdge(toSuperviewSafeArea: .leading)
        contentTextView.autoPinEdge(toSuperviewSafeArea: .trailing)
        
        // forward delegate
        contentTextView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // countlabel
        contentView.addSubview(contentTextViewCountLabel)
        contentTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: -88)
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
}
