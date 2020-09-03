//
//  PostEditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension PostEditorVC {
    @objc func layoutTopContentTextView() {
        // title
        contentView.addSubview(titleTextView)
        titleTextView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        titleTextView.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        titleTextView.autoPinEdge(.top, to: .bottom, of: communityView, withOffset: 5)
        
        // countLabel
        contentView.addSubview(titleTextViewCountLabel)
        titleTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 8)
        titleTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        contentTextView.autoPinEdge(.top, to: .bottom, of: titleTextView, withOffset: 28)
    }
    
    @objc func layoutBottomContentTextView() {
        contentTextView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    override func layoutContentView() {
        // community
        contentView.addSubview(communityView)
        communityView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        communityView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseCommunityDidTouch))
        communityView.addGestureRecognizer(tap)
        
        let hStack: UIStackView = {
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            
            stackView.addArrangedSubview(communityAvatarImage)
            
            let vStack: UIStackView = {
                let stackView = UIStackView(axis: .vertical, alignment: .leading, distribution: .fill)
                stackView.addArrangedSubviews([youWillPostInLabel, communityNameLabel])
                return stackView
            }()
            stackView.addArrangedSubview(vStack)
            let dropdownButton = UIButton.circleGray(imageName: "drop-down")
            stackView.addArrangedSubview(dropdownButton)
            return stackView
        }()
        
        communityView.addSubview(hStack)
        hStack.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16))
        
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
