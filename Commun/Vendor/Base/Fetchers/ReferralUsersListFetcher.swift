//
//  ReferralUsersListFetcher.swift
//  Commun
//
//  Created by Chung Tran on 3/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ReferralUsersListFetcher: ListFetcher<ResponseAPIContentGetProfile> {
    override var request: Single<[ResponseAPIContentGetProfile]> {
        RestAPIManager.instance.getReferralUsers(offset: offset, limit: limit)
            .map {$0.items}
    }
}
