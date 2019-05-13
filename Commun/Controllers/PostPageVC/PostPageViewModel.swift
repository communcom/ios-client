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

class PostPageViewModel {
    // MARK: - Inputs
    var postForRequest: ResponseAPIContentGetPost?
    var permlink: String?
    var refBlockNum: UInt64?
    var userId: String?
    
    // MARK: - Objects
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    let comments = BehaviorRelay<[ResponseAPIContentGetComment]>(value: [])
    
    let disposeBag = DisposeBag()
    let fetcher = CommentsFetcher()
    
    // MARK: - Methods
    func loadPost() {
        if postForRequest != nil {post.accept(postForRequest)}
        let permLink = postForRequest?.contentId.permlink ?? permlink ?? ""
        let refBlock = postForRequest?.contentId.refBlockNum ?? refBlockNum ?? 0
        let userId = postForRequest?.contentId.userId ?? self.userId ?? ""
        
        // Bind post
        NetworkService.shared.getPost(withPermLink: permLink,
                                      withRefBlock: refBlock,
                                      forUser: userId)
            .bind(to: post)
            .disposed(by: disposeBag)
        
        // Configure fetcher
        fetcher.permlink = permLink
        fetcher.refBlockNum = refBlock
        fetcher.userId = userId
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .catchError { (error) -> Single<[ResponseAPIContentGetComment]> in
                #warning("handle error")
                return .just([])
            }
            .subscribe(onSuccess: { (list) in
                self.comments.accept(self.comments.value + list)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        fetcher.reset()
        fetchNext()
    }
}
