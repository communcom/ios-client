//
//  LeaderController.swift
//  Commun
//
//  Created by Chung Tran on 11/5/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
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

extension ResponseAPIContentGetLeader {
    mutating func setIsVoted(_ value: Bool) {
        guard value != isVoted else {return}
        isVoted = value
    }
}

extension LeaderController {
    func observeLeaderChange() {
        ResponseAPIContentGetLeader.observeItemChanged()
            .filter {$0.identity == self.leader?.identity}
            .subscribe(onNext: {newLeader in
                self.setUp(with: newLeader)
            })
            .disposed(by: disposeBag)
    }
    
    func toggleVote() {
        guard let leader = leader else {return}
        voteButton.animate {
            NetworkService.shared.toggleVoteLeader(leader: leader)
                .subscribe { (error) in
                    UIApplication.topViewController()?.showError(error)
                }
                .disposed(by: self.disposeBag)
        }
    }
}
