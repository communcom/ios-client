//
//  FavouriteManager.swift
//  Commun
//
//  Created by Chung Tran on 10/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class FavouritesList {
    /// Singleton
    private init() {}
    static var shared = FavouritesList()
    private let bag = DisposeBag()
    
    /// List of favourite posts' permlink
    var list = [String]()
    
    /// Retrieve list of favourites posts and save them into singleton
    func retrieve() {
        RestAPIManager.instance.getFavorites()
            .map {favouriteResult in
                return favouriteResult.list.compactMap {$0}
            }
            .subscribe(onSuccess: {list in
                self.list = list
            })
            .disposed(by: bag)
    }
    
    /// Add to favourite
    func add(permlink: String) -> Completable {
        return RestAPIManager.instance.addFavorites(permlink: permlink)
            .flatMapToCompletable()
            .do(onCompleted: {
                self.list.appendIfNotContains(permlink)
            })
    }
    
    /// Remove from favourite
    func remove(permlink: String) -> Completable {
        return RestAPIManager.instance.removeFavorites(permlink: permlink)
            .flatMapToCompletable()
            .do(onCompleted: {
                self.list.removeAll(permlink)
            })
    }
}
