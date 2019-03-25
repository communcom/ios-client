//
//  PostPageViewModel.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 21/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class PostPageViewModel {
    
    var postForRequest: ResponseAPIContentGetPost?
    
    var post = Variable<ResponseAPIContentGetPost?>(nil)
    var comments = Variable<[ResponseAPIContentGetComment]>([])
    
    let disposeBag = DisposeBag()
    
    func loadPost() {
        NetworkService.shared.getPost(withPermLink: postForRequest?.contentId.permlink ?? "",
                                      withRefBlock: postForRequest?.contentId.refBlockNum ?? 0,
                                      forUser: postForRequest?.contentId.userId ?? "").subscribe(onNext: { [weak self] post in
            self?.post.value = post
        }).disposed(by: disposeBag)
    }
    
    func loadComments() {
        NetworkService.shared.getPostComment(withPermLink: postForRequest?.contentId.permlink ?? "",
                                             withRefBlock: postForRequest?.contentId.refBlockNum ?? 0,
                                             forUser: postForRequest?.contentId.userId ?? "").subscribe(onNext: { [weak self] comments in
            self?.comments.value = comments.items ?? []
        }).disposed(by: disposeBag)
    }
}
