//
//  PostPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class PostPageViewModel: CommentsViewModel {
    // MARK: - Input
    var postForRequest: ResponseAPIContentGetPost?
    var userId: String
    var permlink: String
    var communityId: String
    
    // MARK: - Objects
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        self.userId = post.contentId.userId
        self.permlink = post.contentId.permlink
        self.communityId = post.contentId.communityId ?? ""
        self.postForRequest = post
        super.init(filter: CommentsListFetcher.Filter(sortBy: .popularity, type: .post, userId: post.contentId.userId, permlink: post.contentId.permlink))
        defer {setUp()}
    }
    
    init(userId: String, permlink: String, communityId: String) {
        self.userId = userId
        self.permlink = permlink
        self.communityId = communityId
        super.init(filter: CommentsListFetcher.Filter(type: .post, userId: userId, permlink: permlink))
        defer {setUp()}
    }
    
    func setUp() {
        loadPost()
        fetchNext()
        bind()
    }
    
    func loadPost() {
        RestAPIManager.instance.loadPost(userId: userId, permlink: permlink, communityId: communityId)
            .do(onSuccess: { (profile) in
                self.loadingState.accept(.finished)
            }, onError: { (error) in
                self.loadingState.accept(.error(error: error))
            }, onSubscribe: {
                self.loadingState.accept(.loading)
            })
            .catchError({ (error) -> Single<ResponseAPIContentGetPost> in
                if let post = self.postForRequest {
                    return .just(post)
                }
                throw error
            })
            .asObservable()
            .bind(to: post)
            .disposed(by: disposeBag)
    }
    
    func bind() {
        
    }
    
    override func reload() {
        super.reload()
        loadPost()
    }
}
