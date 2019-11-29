//
//  LeaderController.swift
//  Commun
//
//  Created by Chung Tran on 11/5/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import CyberSwift

protocol LeaderController: class {
    var disposeBag: DisposeBag {get}
    var voteButton: CommunButton {get set}
    var leader: ResponseAPIContentGetLeader? {get set}
    func setUp(with leader: ResponseAPIContentGetLeader)
}

extension LeaderController {
    func observeLeaderChange() {
        ResponseAPIContentGetLeader.observeItemChanged()
            .subscribe(onNext: {newLeader in
                self.setUp(with: newLeader)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleVote() {
        guard leader != nil, let communityId = leader?.communityId else {return}
        
        let originIsVoted = leader!.votesCount > 0
        
        // set value
        setIsVoted(!originIsVoted)
        leader?.isBeingVoted = true
        
        // animate
        animateVote()
        
        // notify change
        leader?.notifyChanged()
        
        // send request
        let request: Single<String>
//        request = Single<String>.just("")
//            .delay(0.8, scheduler: MainScheduler.instance)
        if originIsVoted {
            // unvote
            request = RestAPIManager.instance.unvoteLeader(communityId: communityId, leader: leader!.userId)
        }
        else {
            request = RestAPIManager.instance.voteLeader(communityId: communityId, leader: leader!.userId)
        }
        
        request
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: { [weak self] in
                // re-enable state
                self?.leader?.isBeingVoted = false
                self?.leader?.notifyChanged()
            }) { [weak self](error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsVoted(originIsVoted)
                self?.leader?.isBeingVoted = false
                strongSelf.leader?.notifyChanged()
                
                // show error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func setIsVoted(_ value: Bool) {
        guard var leaderValue = leader, leaderValue.votesCount > 0 else { return }
        leaderValue.votesCount += value.int
    }
    
    func animateVote() {
        CATransaction.begin()
        
        let moveDownAnim = CABasicAnimation(keyPath: "transform.scale")
        moveDownAnim.byValue = 1.2
        moveDownAnim.autoreverses = true
        voteButton.layer.add(moveDownAnim, forKey: "transform.scale")
        
        let fadeAnim = CABasicAnimation(keyPath: "opacity")
        fadeAnim.byValue = -1
        fadeAnim.autoreverses = true
        voteButton.layer.add(fadeAnim, forKey: "Fade")
        
        CATransaction.commit()
    }
}
