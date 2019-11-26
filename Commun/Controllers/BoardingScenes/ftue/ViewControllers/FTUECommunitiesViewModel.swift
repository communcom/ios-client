//
//  FTUECommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class FTUECommunitiesViewModel: CommunitiesViewModel {
    override func observeItemChange() {
        ResponseAPIContentGetSubscriptionsCommunity.observeItemChanged()
            .subscribe(onNext: { (community) in
                let community = ResponseAPIContentGetCommunity(community: community)
                self.updateItem(community)
            })
            .disposed(by: disposeBag)
    }
    
    override func observeItemDeleted() {
        ResponseAPIContentGetSubscriptionsCommunity.observeItemDeleted()
            .subscribe(onNext: { (community) in
                let community = ResponseAPIContentGetCommunity(community: community)
                self.deleteItem(community)
            })
            .disposed(by: disposeBag)
    }
}
