//
//  CommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 8/2/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class CommunitiesViewModel {
    let filter  = BehaviorRelay<CommunityFilter>(value: CommunityFilter(text: nil, joined: false))
    let items   = BehaviorRelay<[MockupCommunity]>(value: MockupCommunity.mockupData)
    
    func applyFilter(text: String? = nil, joined: Bool? = nil) {
        var newFilter = filter.value
        
        if let text = text {
            if text.count == 0 {
                newFilter.text = nil
            } else {
                newFilter.text = text
            }
        }
        
        if let joined = joined {
            newFilter.joined = joined
        }
        
        filter.accept(newFilter)
    }
}
