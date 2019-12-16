//
//  VoteContainerView.swift
//  Commun
//
//  Created by Chung Tran on 11/8/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift

class VoteContainerView: MyView {
    // MARK: - Subviews
    lazy var upVoteButton = UIButton.vote(type: .upvote)
    lazy var downVoteButton = UIButton.vote(type: .downvote)
    lazy var likeCountLabel = UILabel.with(textSize: 12, weight: .bold, textColor: UIColor(hexString: "#A5A7BD")!, textAlignment: .center)
    
    // MARK: - Methods
    override func commonInit() {
        super.commonInit()
        backgroundColor = .f3f5fa
        setContentHuggingPriority(.defaultHigh, for: .horizontal)

        addSubview(upVoteButton)
        upVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        addSubview(downVoteButton)
        downVoteButton.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .leading)
        
        addSubview(likeCountLabel)
        likeCountLabel.autoPinEdge(.leading, to: .trailing, of: upVoteButton)
        likeCountLabel.autoPinEdge(.trailing, to: .leading, of: downVoteButton)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .top)
        likeCountLabel.autoPinEdge(toSuperviewEdge: .bottom)
        likeCountLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    func setUp(with votes: ResponseAPIContentVotes, userID: String?) {
        upVoteButton.tintColor         = votes.hasUpVote ?? false ? .appMainColor : .a5a7bd
        likeCountLabel.text            = "\(Double((votes.upCount ?? 0) - (votes.downCount ?? 0)).kmFormatted)"
        downVoteButton.tintColor       = votes.hasDownVote ?? false ? .appMainColor : .a5a7bd
        upVoteButton.isEnabled         = !(votes.isBeingVoted ?? false)
        downVoteButton.isEnabled       = !(votes.isBeingVoted ?? false)
        likeCountLabel.textColor = votes.hasUpVote ?? false || votes.hasDownVote ?? false ? .appMainColor : .a5a7bd

        let isCurrentUser = Config.currentUser?.id == userID
        upVoteButton.isHidden = isCurrentUser
        downVoteButton.isHidden = isCurrentUser
    }
    
    func animateUpVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)

        let moveUpAnim = CABasicAnimation(keyPath: "position.y")
        moveUpAnim.byValue = -16
        moveUpAnim.autoreverses = true
        self.upVoteButton.layer.add(moveUpAnim, forKey: "moveUp")

        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.upVoteButton.layer.add(fadeAnim, forKey: "Fade")

        CATransaction.commit()
    }
    
    func animateDownVote(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        
        let moveDownAnim = CABasicAnimation(keyPath: "position.y")
        moveDownAnim.byValue = 16
        moveDownAnim.autoreverses = true
        self.downVoteButton.layer.add(moveDownAnim, forKey: "moveDown")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        self.downVoteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
