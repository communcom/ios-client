//
//  ProfileViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel<ProfileType: Decodable>: BaseViewModel {
    // MARK: - Input
    var profileForRequest: ProfileType?
    var profileId: String?
    
    // MARK: - Objects
    let loadingState = BehaviorRelay<LoadingState>(value: .loading)
    let listLoadingState = BehaviorRelay<ListFetcherState>(value: .loading(false))
    let profile = BehaviorRelay<ProfileType?>(value: nil)
    let items = BehaviorRelay<[Any]>(value: [])
    
    // MARK: - Initializers
    init(profileId: String?, prefetch: Bool = true) {
        super.init()
        self.profileId = profileId
        
        defer {
            if prefetch {
                loadProfile()
            }
            bind()
        }
    }
    
    // MARK: - Methods
    var loadProfileRequest: Single<ProfileType> {
        fatalError("Must override")
    }
    
    func loadProfile() {
        loadProfileRequest
            .map {$0 as ProfileType?}
            .do(onSuccess: { (profile) in
                self.loadingState.accept(.finished)
            }, onError: { (error) in
                self.loadingState.accept(.error(error: error))
            }, onSubscribe: {
                self.loadingState.accept(.loading)
            })
            .asDriver(onErrorJustReturn: profileForRequest)
            .drive(profile)
            .disposed(by: disposeBag)
    }
    
    var listLoadingStateObservable: Observable<ListFetcherState> {
        fatalError("Must override")
    }
    
    func bind() {
        listLoadingStateObservable
            .distinctUntilChanged { (lhs, rhs) -> Bool in
                switch (lhs, rhs) {
                case (.loading(let isLoading1), .loading(let isLoading2)):
                    return isLoading1 == isLoading2
                case (.listEnded, .listEnded):
                    return true
                default:
                    return false
                }
            }
            .bind(to: listLoadingState)
            .disposed(by: disposeBag)
    }
    
    func reload() {
        // reload profile
        profile.accept(nil)
        
        // retrieve
        loadProfile()
    }
    
    func fetchNext(forceRetry: Bool = false) {
        
    }
}
