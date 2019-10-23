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
    
    // MARK: - Inputs
    var postForRequest: ResponseAPIContentGetPost?
    var permlink: String?
    var userId: String?
    
    // MARK: - Objects
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    
    // MARK: - Methods
    convenience init() {
        self.init(filter: CommentsListFetcher.Filter(type: .post))
        defer {
            loadPost()
            post.subscribe(onNext: { (post) in
                guard let post = post else {return}
                let permLink = post.contentId.permlink
                let userId = post.contentId.userId
                // Configure fetcher
                (self.fetcher as! CommentsListFetcher).filter.communityId = post.community.communityId
                (self.fetcher as! CommentsListFetcher).filter.permlink = permLink
                (self.fetcher as! CommentsListFetcher).filter.userId = userId
    
                self.reload()
            })
            .disposed(by: disposeBag)
        }
    }
    
    func loadPost() {
        let permLink = postForRequest?.contentId.permlink ?? permlink ?? ""
        
        // Bind post
        NetworkService.shared.getPost(withPermLink: permLink)
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
}
