//
//  PostListController.swift
//  Commun
//
//  Created by Chung Tran on 24/05/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxCocoa
import RxSwift
import RxDataSources

protocol ItemsListController {
    associatedtype T: Decodable & Equatable & IdentifiableType
    var fetcher: ListFetcher<T> {get set}
    var disposeBag: DisposeBag {get}
}

extension ItemsListController {
    func updateItem(_ updatedItem: T) {
        var newItems = fetcher.items.value
        guard let index = newItems.firstIndex(where: {$0.identity == updatedItem.identity}) else {return}
        newItems[index] = updatedItem
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(newItems)
        UIView.setAnimationsEnabled(true)
    }
    
    func deleteItem(_ deletedItem: T) {
        let newItems = fetcher.items.value.filter {$0.identity != deletedItem.identity}
        UIView.setAnimationsEnabled(false)
        fetcher.items.accept(newItems)
        UIView.setAnimationsEnabled(true)
    }
}

protocol PostsListController: ItemsListController where T == ResponseAPIContentGetPost {}

extension PostsListController {
    func observePostDelete() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidDeleteNotification))
            .subscribe(onNext: { (notification) in
                guard let deletedPost = notification.object as? ResponseAPIContentGetPost
                    else {return}
                self.deleteItem(deletedPost)
            })
            .disposed(by: disposeBag)
    }
    
    func observePostChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: PostControllerPostDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newPost = notification.object as? ResponseAPIContentGetPost
                    else {return}
                self.updateItem(newPost)
            })
            .disposed(by: disposeBag)
    }
}

protocol CommentsListController: ItemsListController where T == ResponseAPIContentGetComment {}

extension CommentsListController {
    func observeCommentChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommentControllerCommentDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newComment = notification.object as? ResponseAPIContentGetComment
                    else {return}
                self.updateItem(newComment)
            })
            .disposed(by: disposeBag)
    }
    func observeCommentDelete() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommentControllerCommentDeletedNotification))
            .subscribe(onNext: { (notification) in
                guard let newComment = notification.object as? ResponseAPIContentGetComment
                    else {return}
                self.deleteItem(newComment)
            })
            .disposed(by: disposeBag)
    }
}

protocol CommunitiesListController: ItemsListController where T == ResponseAPIContentGetCommunity {}

extension CommunitiesListController {
    func observeCommunityChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommunityControllerCommunityDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? ResponseAPIContentGetCommunity
                    else {return}
                self.updateItem(newCommunity)
            })
            .disposed(by: disposeBag)
    }
    
    func observeCommunityDeleted() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommunityControllerCommunityDeletedNotification))
            .subscribe(onNext: {notification in
                guard let deletedCommunity = notification.object as? ResponseAPIContentGetCommunity
                    else {return}
                self.deleteItem(deletedCommunity)
            })
            .disposed(by: disposeBag)
    }
}

protocol ProfilesListController: ItemsListController where T == ResponseAPIContentResolveProfile {}

extension ProfilesListController {
    func observeProfileChange() {
        NotificationCenter.default.rx.notification(.init(rawValue: ProfileControllerProfileDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newCommunity = notification.object as? ResponseAPIContentResolveProfile
                    else {return}
                self.updateItem(newCommunity)
            })
            .disposed(by: disposeBag)
    }
}
