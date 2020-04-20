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
        let votedLeader = leadersVM.items.value.first(where: {$0.isVoted == true})
        if votedLeader != nil {
            self.showAlert(title: "are you sure you want to take the vote back?".localized().uppercaseFirst, message: "please consider that you have only 1 vote. By giving it to another nominee, you'll reduce your currently chosen nominee's influence equal to the current number of your Points.".localized().uppercaseFirst, buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst], highlightedButtonIndex: 1)
            { (index) in
                if index == 0 {
                    if leader.identity == votedLeader?.identity {
                        BlockchainManager.instance.toggleVoteLeader(leader: leader)
                            .subscribe { (error) in
                                UIApplication.topViewController()?.showError(error)
                            }
                            .disposed(by: self.disposeBag)
                        return
                    }
                    
                    BlockchainManager.instance.toggleVoteLeader(leader: votedLeader!)
                        .do(onError: { (error) in
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
                        .subscribe { (error) in
                            UIApplication.topViewController()?.showError(error)
                        }
                        .disposed(by: self.disposeBag)
                }
            }
        } else {
            BlockchainManager.instance.toggleVoteLeader(leader: leader)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: disposeBag)
        }
    }
    
    func buttonFollowDidTouch(leader: ResponseAPIContentGetLeader) {
        BlockchainManager.instance.triggerFollow(user: leader)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
