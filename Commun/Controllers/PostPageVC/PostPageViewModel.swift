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
    // MARK: - Objects
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let post: BehaviorRelay<ResponseAPIContentGetPost?>
    
    // MARK: - Initializers
    init(post: ResponseAPIContentGetPost) {
        self.post = BehaviorRelay<ResponseAPIContentGetPost?>(value: post)
        super.init(filter: CommentsListFetcher.Filter(sortBy: .popularity, type: .post, userId: post.contentId.userId, permlink: post.contentId.permlink, communityId: post.community?.communityId))
        defer {
            loadPost()
            bind()
        }
    }
    
    init(userId: String?, username: String?, permlink: String, communityId: String?, communityAlias: String?) {
        self.post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
        super.init(filter: CommentsListFetcher.Filter(sortBy: .popularity, type: .post, userId: userId, username: username, permlink: permlink, communityId: communityId, communityAlias: communityAlias))
        defer {
            loadPost()
            bind()
            fetchNext(forceRetry: true)
        }
    }
    
    func loadPost() {
        RestAPIManager.instance.loadPost(userId: filter.value.userId, username: filter.value.username, permlink: filter.value.permlink!, communityId: filter.value.communityId, communityAlias: filter.value.communityAlias)
            .do(onSubscribe: {
                self.loadingState.accept(.loading)
            })
            .subscribe(onSuccess: { post in
                if self.post.value == nil {
                    self.post.accept(post)
                }
                self.loadingState.accept(.finished)
            }, onError: { (error) in
                self.loadingState.accept(.error(error: error))
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
