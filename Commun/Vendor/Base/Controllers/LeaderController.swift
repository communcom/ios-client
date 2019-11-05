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

let LeaderControllerLeaderDidChangeNotification = "LeaderControllerLeaderDidChangeNotification"

extension ResponseAPIContentGetLeader {
    public func notifyChanged() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: LeaderControllerLeaderDidChangeNotification), object: self)
    }
}

protocol LeaderController: class {
    var disposeBag: DisposeBag {get}
    var voteButton: CommunButton {get set}
    var leader: ResponseAPIContentGetLeader? {get set}
    func setUp(with leader: ResponseAPIContentGetLeader)
}

extension LeaderController {
    func observeLeaderChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: LeaderControllerLeaderDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newLeader = notification.object as? ResponseAPIContentGetLeader,
                    newLeader == self.leader
                    else {return}
                self.setUp(with: newLeader)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleVote() {
        guard leader != nil else {return}
        
        let originIsVoted = leader?.isVoted ?? false
        
        // set value
        setIsVoted(!originIsVoted)
        
        // animate
        animateVote()
        
        // notify change
        leader?.notifyChanged()
        
        // send request
        #warning("mock request")
        Completable.empty()
            .delay(0.8, scheduler: MainScheduler.instance)
            .do(onSubscribe: { [weak self] in
                self?.voteButton.isEnabled = false
            })
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
