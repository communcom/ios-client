//
//  PostPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class PostPageViewModel: CommentsViewModel {
    // MARK: - Input
    var postForRequest: ResponseAPIContentGetPost?
    var username: String?
    var communityAlias: String?
    
    // MARK: - Objects
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        self.postForRequest = post
        super.init(filter: CommentsListFetcher.Filter(sortBy: .popularity, type: .post, userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.community?.communityId))
        defer { setUp() }
    }
    
    init(userId: String?, username: String?, permlink: String, communityId: String?, communityAlias: String?) {
        self.username = username
        self.communityAlias = communityAlias
        
        super.init(filter: CommentsListFetcher.Filter(type: .post, userId: userId, permlink: permlink, communityId: communityId))
        defer { setUp() }
    }
    
    func setUp() {
        loadPost()
        fetchNext()
        bind()
    }
    
    override func fetchNext(forceRetry: Bool = false) {
        if filter.value.userId == nil && filter.value.communityId == nil {
            return
        }
        super.fetchNext(forceRetry: forceRetry)
    }
    
    func loadPost() {
        RestAPIManager.instance.loadPost(userId: filter.value.userId, username: username, permlink: filter.value.permlink!, communityId: filter.value.communityId, communityAlias: communityAlias)
            .do(onSuccess: { (post) in
                self.loadingState.accept(.finished)
                if self.filter.value.userId == nil || self.filter.value.communityId == nil {
                    self.changeFilter(userId: post.contentId.userId, communityId: post.contentId.communityId)
                }
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
            .subscribe(onSuccess: { (post) in
                let originalPost = self.post.value ?? self.postForRequest
                let postTemp = originalPost?.newUpdatedItem(from: post)
                var newPost = postTemp ?? post
                newPost.viewsCount = max((post.viewsCount ?? 0), (postTemp?.viewsCount ?? 0))
                self.post.accept(newPost)
            })
            .disposed(by: disposeBag)
    }
    
    func bind() {
        ResponseAPIContentGetPost.observeItemChanged()
            .filter {$0.identity == self.post.value?.identity}
            .subscribe(onNext: { post in
                guard let newPost = self.post.value?.newUpdatedItem(from: post) else {return}
                self.post.accept(newPost)
            })
            .disposed(by: disposeBag)
    }
    
    override func reload(clearResult: Bool = true) {
        loadPost()
        super.reload(clearResult: clearResult)
    }
}
