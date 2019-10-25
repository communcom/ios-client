//
//  EditorVC+Layout.swift
//  Commun
//
//  Created by Chung Tran on 10/4/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension EditorVC {
    @objc func layoutTopContentTextView() {
        fatalError("Must override")
    }
    
    @objc func layoutBottomContentTextView() {
        fatalError("Must override this method")
    }
    
    func setUpToolbar() {
        view.addSubview(toolbar)
        toolbar.backgroundColor = .white
        toolbar.clipsToBounds = true
        toolbar.cornerRadius = 16
        toolbar.addShadow(ofColor: UIColor(red: 56, green: 60, blue: 71)!, radius: 16, offset: CGSize(width: 0, height: -6), opacity: 0.07)
        
        toolbar.autoPinEdge(toSuperviewSafeArea: .leading)
        toolbar.autoPinEdge(toSuperviewSafeArea: .trailing)
        toolbar.autoSetDimension(.height, toSize: 55 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0))
        let keyboardViewV = KeyboardLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: toolbar, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        keyboardViewV.observeKeyboardHeight()
        self.view.addConstraint(keyboardViewV)
        
        // buttons
        setUpToolbarButtons()
        
        // sendpost button
        toolbar.addSubview(postButton)
        postButton.autoPinEdge(.leading, to: .trailing, of: buttonsCollectionView, withOffset: 10)
        postButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        postButton.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
    }
    
    func setUpToolbarButtons() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        buttonsCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        buttonsCollectionView.showsHorizontalScrollIndicator = false
        buttonsCollectionView.backgroundColor = .clear
        buttonsCollectionView.configureForAutoLayout()
        toolbar.addSubview(buttonsCollectionView)
        // layout
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        buttonsCollectionView.autoPinEdge(toSuperviewEdge: .left, withInset: 0)
        buttonsCollectionView.autoSetDimension(.height, toSize: 45)
        
        buttonsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        buttonsCollectionView.register(EditorToolbarItemCell.self, forCellWithReuseIdentifier: "EditorToolbarItemCell")
    }
    
    func addScrollView() {
        let scrollView = UIScrollView(forAutoLayout: ())
        view.addSubview(scrollView)
        scrollView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), excludingEdge: .bottom)
        scrollView.autoPinEdge(.bottom, to: .top, of: toolbar, withOffset: -12)
        
        // add childview of scrollview
        contentView = UIView(forAutoLayout: ())
        scrollView.addSubview(contentView)
        contentView.autoPinEdgesToSuperviewEdges()
        contentView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    }
    
    func layoutContentView() {
        // header
        contentView.addSubview(closeButton)
        contentView.addSubview(headerLabel)
        closeButton.autoPinEdge(toSuperviewEdge: .top, withInset: 25)
        closeButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        headerLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        headerLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)
        
        // community
        contentView.addSubview(communityAvatarImage)
        contentView.addSubview(youWillPostIn)
        contentView.addSubview(communityNameLabel)
        contentView.addSubview(dropdownButton)
        
        communityAvatarImage.autoPinEdge(.top, to: .bottom, of: closeButton, withOffset: 25)
        communityAvatarImage.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        
        youWillPostIn.autoPinEdge(.top, to: .top, of: communityAvatarImage, withOffset: 5)
        youWillPostIn.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        
        communityNameLabel.autoPinEdge(.leading, to: .trailing, of: communityAvatarImage, withOffset: 10)
        communityNameLabel.autoPinEdge(.bottom, to: .bottom, of: communityAvatarImage, withOffset: -4)
        
        dropdownButton.autoAlignAxis(.horizontal, toSameAxisOf: communityAvatarImage)
        dropdownButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
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
        contentTextViewCountLabel.autoPinEdge(.top, to: .bottom, of: contentTextView, withOffset: -188)
        contentTextViewCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
    }
}
