//
//  PostHeaderView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class PostHeaderView: MyTableHeaderView, PostController {
    // MARK: - Constants
    let voteActionsContainerViewHeight: CGFloat = 35
    
    // MARK: - Properties
    let disposeBag = DisposeBag()
    
    // MARK: - Subviews
    lazy var titleLabel = UILabel.with(text: "Discussion - The Dangerous Path Overwatch is Headed: Giving Players", textSize: 21, weight: .bold, numberOfLines: 0)
    lazy var contentTextView = PostHeaderTextView(forExpandable: ())
    lazy var voteContainerView = VoteContainerView(height: voteActionsContainerViewHeight, cornerRadius: voteActionsContainerViewHeight / 2)
    
    var post: ResponseAPIContentGetPost?
    
    func setUp(with post: ResponseAPIContentGetPost?) {
        <#code#>
    }
    
    
}
