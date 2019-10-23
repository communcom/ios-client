//
//  CommunityHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class CommunityHeaderView: MyTableHeaderView {
    // MARK: - Subviews
    lazy var backButton: UIButton = {
        let button = UIButton(width: 24, height: 40, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 12))
        button.tintColor = .white
        button.setImage(UIImage(named: "back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: 180)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    lazy var contentView: UIView = {
        let view = UIView(height: 243, backgroundColor: .white)
        view.cornerRadius = 25
        return view
    }()
    
    override func commonInit() {
        super.commonInit()
        backgroundColor = .white
        
        addSubview(backButton)
        backButton.autoPinEdge(toSuperviewSafeArea: .top, withInset: 8)
        backButton.autoPinEdge(toSuperviewSafeArea: .leading, withInset: 16)
        
        addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        bringSubviewToFront(backButton)
        
        addSubview(contentView)
        contentView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: -25)
        contentView.autoPinEdge(toSuperviewEdge: .leading)
        contentView.autoPinEdge(toSuperviewEdge: .trailing)
        
        #warning("remove later")
        contentView.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    @objc func backButtonTapped(_ sender: UIButton) {
        parentViewController?.back()
    }
}
