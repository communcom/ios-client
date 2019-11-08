//
//  VoteContainerView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class VoteContainerView: MyView {
    // MARK: - Subviews
    lazy var upVoteButton = UIButton.vote(type: .upvote)
    lazy var downVoteButton = UIButton.vote(type: .downvote)
    lazy var likeCountLabel = UILabel.with(textSize: 12, weight: .medium, textColor: UIColor(hexString: "#A5A7BD")!)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        backgroundColor = .f3f5fa
        
        addSubview(upVoteButton)
        upVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        addSubview(downVoteButton)
        downVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        addSubview(likeCountLabel)
        likeCountLabel.autoPinEdge(.leading, to: .trailing, of: upVoteButton)
        likeCountLabel.autoPinEdge(.trailing, to: .leading, of: downVoteButton)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .top)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .bottom)
    }
    
    func setUp(with votes: ResponseAPIContentVotes) {
        upVoteButton.tintColor         = votes.hasUpVote ?? false ? .appMainColor: .lightGray
        likeCountLabel.text            =   "\((votes.upCount ?? 0) - (votes.downCount ?? 0))"
        downVoteButton.tintColor       = votes.hasDownVote ?? false ? .appMainColor: .lightGray
    }
}
