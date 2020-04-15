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

extension LeaderCellDelegate where Self: BaseViewController {
    func buttonVoteDidTouch(leader: ResponseAPIContentGetLeader) {
        NetworkService.shared.toggleVoteLeader(leader: leader)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func buttonFollowDidTouch(leader: ResponseAPIContentGetLeader) {
        BlockchainManager.instance.triggerFollow(user: leader)
            .subscribe { (error) in
                UIApplication.topViewController()?.showError(error)
            }
            .disposed(by: disposeBag)
    }
}
