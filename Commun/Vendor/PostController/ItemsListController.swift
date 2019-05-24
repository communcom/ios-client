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

protocol ItemsListController {
    associatedtype T: Equatable
    var items: BehaviorRelay<[T]> {get set}
    var disposeBag: DisposeBag {get}
}

extension ItemsListController {
    func deleteItem(_ deletedItem: T) {
        let newItems = items.value.filter {$0 != deletedItem}
        items.accept(newItems)
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
}
