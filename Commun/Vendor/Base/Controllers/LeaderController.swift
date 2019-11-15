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
        
        let originIsVoted = leader?.isVoted ?? false
        
        // set value
        setIsVoted(!originIsVoted)
        
        // animate
        animateVote()
        
        // notify change
        leader?.notifyChanged()
        
        // send request
//        Completable.empty()
//            .delay(0.8, scheduler: MainScheduler.instance)
        RestAPIManager.instance.rx.voteLeader(communityId: communityId, leader: leader!.userId)
            .do(onSubscribe: { [weak self] in
                self?.voteButton.isEnabled = false
            })
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: { [weak self] in
                // re-enable button state
                self?.voteButton.isEnabled = true
            }) { [weak self](error) in
                guard let strongSelf = self else {return}
                // reverse change
                strongSelf.setIsVoted(originIsVoted)
                strongSelf.leader?.notifyChanged()
                
                // re-enable button state
                strongSelf.voteButton.isEnabled = true
                
                // show error
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func setIsVoted(_ value: Bool) {
        guard leader != nil,
            value != leader?.isVoted
        else {return}
        
        leader?.isVoted = value
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
