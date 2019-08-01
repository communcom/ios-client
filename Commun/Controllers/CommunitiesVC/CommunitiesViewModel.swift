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
    let filter  = BehaviorRelay<CommunityFilter>(value: .discover)
    let items   = BehaviorRelay<[MockupCommunity]>(value: MockupCommunity.mockupData)
}
