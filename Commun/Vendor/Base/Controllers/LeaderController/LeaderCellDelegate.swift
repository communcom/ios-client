//
//  LeaderCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

protocol LeaderCellDelegate: class {
    func buttonVoteDidTouch(leader: ResponseAPIContentGetLeader)
    func buttonFollowDidTouch(leader: ResponseAPIContentGetLeader)
}

protocol HasLeadersVM: class {
    var leadersVM: LeadersViewModel {get}
}

extension LeaderCellDelegate where Self: BaseViewController & HasLeadersVM {
    func buttonVoteDidTouch(leader: ResponseAPIContentGetLeader) {
        // Prevent upvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            nonAuthVC.showAuthVC()
            return
        }
        
        if leadersVM.items.value.first(where: {$0.isBeingVoted == true}) != nil {
            showAlert(title: "please wait".localized().uppercaseFirst, message: "please wait for last operations to finish".localized().uppercaseFirst)
            return
        }
        let votedLeader = leadersVM.items.value.first(where: {$0.isVoted == true})
        if votedLeader != nil {
            self.showAlert(title: "are you sure you want to take the vote back?".localized().uppercaseFirst, message: "please consider that you have only 1 vote. By giving it to another nominee, you'll reduce your currently chosen nominee's influence equal to the current number of your Points.".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1)
            { (index) in
                if index == 0 {
                    if leader.identity == votedLeader?.identity {
                        BlockchainManager.instance.toggleVoteLeader(leader: leader)
                            .subscribe(onError: { (error) in
                                UIApplication.topViewController()?.showError(error)
                            })
                            .disposed(by: self.disposeBag)
                        return
                    }
                    
                    BlockchainManager.instance.toggleVoteLeader(leader: votedLeader!)
                        .do(onError: { (_) in
                            var leader = leader
                            leader.isVoted = false
                            leader.isBeingVoted = false
                            leader.notifyChanged()
                        }, onSubscribe: {
                            var leader = leader
                            leader.isVoted = true
                            leader.isBeingVoted = true
                            leader.notifyChanged()
                        })
                        .andThen(BlockchainManager.instance.toggleVoteLeader(leader: leader))
                        .subscribe(onError:{ (error) in
                            UIApplication.topViewController()?.showError(error)
                        })
                        .disposed(by: self.disposeBag)
                }
            }
        } else {
            BlockchainManager.instance.toggleVoteLeader(leader: leader)
                .subscribe(onError: { (error) in
                    UIApplication.topViewController()?.showError(error)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func buttonFollowDidTouch(leader: ResponseAPIContentGetLeader) {
        // Prevent upvoting when user is in NonAuthVCType
        if let nonAuthVC = self as? NonAuthVCType {
            nonAuthVC.showAuthVC()
            return
        }
        
        BlockchainManager.instance.triggerFollow(user: leader)
            .subscribe(onError: { (error) in
                UIApplication.topViewController()?.showError(error)
            })
            .disposed(by: disposeBag)
    }
}
