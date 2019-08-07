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

class PostPageViewModel: ListViewModelType {
    // MARK: - Handlers
    var loadingHandler: (() -> Void)?
    var listEndedHandler: (() -> Void)?
    var fetchNextErrorHandler: ((Error) -> Void)?
    var fetchNextCompleted: (() -> Void)?
    
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
            .catchError({ (error) -> Single<ResponseAPIContentGetPost> in
                if let post = self.postForRequest {
                    return .just(post)
                }
                throw error
            })
            .asObservable()
            .bind(to: post)
            .disposed(by: disposeBag)
        
        // Configure fetcher
        fetcher.permlink = permLink
        fetcher.userId = userId
    }
    
    func fetchNext() {
        fetcher.fetchNext()
            .do(onSubscribed: {
                self.loadingHandler?()
            })
            .catchError { (error) -> Single<[ResponseAPIContentGetComment]> in
                self.fetchNextErrorHandler?(error)
                return .just([])
            }
            .subscribe(onSuccess: {[weak self] (list) in
                guard let strongSelf = self else {return}
                
                guard list.count > 0 else {
                    strongSelf.listEndedHandler?()
                    return
                }
                
                let newList = strongSelf.sortComments(list.filter {!strongSelf.comments.value.contains($0)})
                strongSelf.comments.accept(strongSelf.comments.value + newList)
                strongSelf.fetchNextCompleted?()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func reload() {
        comments.accept([])
        fetcher.reset()
        fetchNext()
    }
    
    func sortComments(_ comments: [ResponseAPIContentGetComment]) -> [ResponseAPIContentGetComment] {
        return comments
    }
}
