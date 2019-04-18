//
//  ProfilePageViewModel.swift
//  Commun
//
//  Created by Chung Tran on 17/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CyberSwift

class ProfilePageViewModel {
    let profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    
    let posts = BehaviorRelay<[ResponseAPIContentGetPost]>(value: [])
    private let postsFetcher = PostsFetcher()
    
//    let comments = BehaviorRelay<[ResponseAPIContentGetPost]
    
    let bag = DisposeBag()
    
    init() {
        let nonNilProfile = profile.filter {$0 != nil}
            .map {$0!}
            .share()
        
        // Retrieve post after receiving profile
        nonNilProfile
            .flatMapLatest {profile -> Single<[ResponseAPIContentGetPost]> in
                self.postsFetcher.reset()
                return self.postsFetcher.fetchNext()
            }
            .asDriver(onErrorJustReturn: [])
            .drive(posts)
            .disposed(by: bag)
        
        // Retrieve comment
        #warning("retrieve comment")
        
    }
    
    #warning("fetchNext comments")
    func fetchNext() {
        postsFetcher.fetchNext()
            .asDriver(onErrorJustReturn: [])
            .map {self.posts.value + $0}
            .drive(posts)
            .disposed(by: bag)
    }
    
    func reload() {
        // reload profile
        profile.accept(nil)
        
        // reload posts
        postsFetcher.reset()
        posts.accept([])
        
        // reload comments
        #warning("reload comments")
        
        // reload profile
        loadProfile()
    }
    
    func loadProfile() {
        NetworkService.shared.getUserProfile()
            .subscribe(onSuccess: { (profile) in
                self.profile.accept(profile)
            }) { (error) in
                #warning("handle error")
                print(error)
            }
            .disposed(by: bag)
    }
}
