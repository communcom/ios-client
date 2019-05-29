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
    var userId: String?
    
    // MARK: - Objects
    let post = BehaviorRelay<ResponseAPIContentGetPost?>(value: nil)
    let comments = BehaviorRelay<[ResponseAPIContentGetComment]>(value: [])
    
    let disposeBag = DisposeBag()
    let fetcher = CommentsFetcher()
    
    // MARK: - Methods
    func loadPost() {
        let permLink = postForRequest?.contentId.permlink ?? permlink ?? ""
        let userId = postForRequest?.contentId.userId ?? self.userId ?? ""
        
        // Bind post
        NetworkService.shared.getPost(withPermLink: permLink,
                                      forUser: userId)
            .catchError({ (error) -> Observable<ResponseAPIContentGetPost> in
                if let post = self.postForRequest {
                    return .just(post)
                }
                return Observable.empty()
            })
            .bind(to: post)
            .disposed(by: disposeBag)
        
        // Configure fetcher
        fetcher.permlink = permLink
        fetcher.userId = userId
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .catchError { (error) -> Single<[ResponseAPIContentGetComment]> in
                #warning("handle error")
                return .just([])
            }
            .subscribe(onSuccess: { (list) in
                guard list.count > 0 else {return}
                self.comments.accept(self.comments.value + list)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        comments.accept([])
        fetcher.reset()
        fetchNext()
    }
}
