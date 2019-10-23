//
//  CommunityViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift


class CommunityViewModel: PostsViewModel {
    // MARK: - Input
    var communityForRequest: ResponseAPIContentGetCommunity?
    var communityId: String?
    
    // MARK: - Objects
    let community = BehaviorRelay<ResponseAPIContentGetCommunity?>(value: nil)
    
    // MARK: - Initializers
    convenience init(community: ResponseAPIContentGetCommunity?) {
        self.init(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: community?.communityId))
        self.communityForRequest = community
        self.communityId = community?.communityId
        
        defer {
            loadCommunity()
        }
    }
    
    convenience init(communityId: String?) {
        self.init(filter: PostsListFetcher.Filter(feedTypeMode: .community, feedType: .time, sortType: .all, communityId: communityId))
        self.communityId = communityId
        
        defer {
            loadCommunity()
        }
    }
    
    // MARK: - Methods
    func loadCommunity() {
        RestAPIManager.instance.getCommunity(id: communityId ?? "")
            .map {$0 as ResponseAPIContentGetCommunity?}
            .asDriver(onErrorJustReturn: communityForRequest)
            .drive(community)
            .disposed(by: disposeBag)
    }
}
