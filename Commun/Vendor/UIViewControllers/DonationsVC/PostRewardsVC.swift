//
//  PostRewardsVC.swift
//  Commun
//
//  Created by Chung Tran on 9/4/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class PostRewardsVC: DonationsVC {
    // MARK: - Properties
    let post: ResponseAPIContentGetPost
    
    // MARK: - Subviews
    lazy var postMetaView: PostMetaView = {
        let postMetaView = PostMetaView(forAutoLayout: ())
        postMetaView.showMosaic = false
        postMetaView.setUp(post: post)
        return postMetaView
    }()
    
    // MARK: - Initializers
    init?(post: ResponseAPIContentGetPost) {
        self.post = post
        guard let donations = post.donations else {return nil}
        super.init(donations: donations)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        let headerView: UIView = {
            let view = UIView(backgroundColor: .white)
            view.addSubview(closeButton)
            closeButton.autoPinTopAndTrailingToSuperView(inset: 16)
            
            view.addSubview(postMetaView)
            postMetaView.autoPinTopAndLeadingToSuperView(inset: 16)
            
            postMetaView.autoPinEdge(.trailing, to: .leading, of: closeButton, withOffset: 10)
            
            let separator = UIView.spacer(height: 2, backgroundColor: .appLightGrayColor)
            view.addSubview(separator)
            separator.autoPinEdge(.top, to: .bottom, of: postMetaView, withOffset: 16)
            separator.autoPinEdge(toSuperviewEdge: .leading)
            separator.autoPinEdge(toSuperviewEdge: .trailing)
            
            separator.autoPinEdge(toSuperviewEdge: .bottom)
            return view
        }()
        
        stackView.insertArrangedSubview(headerView, at: 0)
    }
}
