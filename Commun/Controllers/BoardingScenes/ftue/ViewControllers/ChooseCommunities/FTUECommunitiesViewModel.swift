//
//  FTUECommunitiesViewModel.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class FTUECommunitiesViewModel: CommunitiesViewModel {
    let chosenCommunities = BehaviorRelay<[ResponseAPIContentGetCommunity]>(value: [])
}
