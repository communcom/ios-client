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
    
    // MARK: - Send comment
    private var embeds: [[String: Any]]!
    func sendComment(_ comment: String, image: UIImage?) -> Completable {
        embeds = [[String: Any]]()
        
        var request: Completable {
            return NetworkService.shared.sendComment(comment: comment, metaData: self.createJsonMetadata(for: comment) ?? "", tags: comment.getTags(), forPostWithPermlink: self.post.value!.contentId.permlink)
        }
        
        if let image = image {
            return NetworkService.shared.uploadImage(image)
                .flatMapCompletable({ (url) -> Completable in
                    self.addImage(with: url)
                    return request
                })
        }
        return request
    }
    
    func createJsonMetadata(for text: String) -> String? {
        for word in text.components(separatedBy: " ") {
            if word.contains("http://") || word.contains("https://") {
                if embeds.first(where: {($0["url"] as? String) == word}) != nil {continue}
                #warning("Define type")
                embeds.append(["url": word])
            }
        }
        
        let result = ["embeds": embeds]
        return result.jsonString()
    }
    
    /// set url = nil to remove
    func addImage(with url: String) {
        if let i = embeds.firstIndex(where: {($0["type"] as? String) == "photo"}) {
            embeds[i]["url"] = url
            return
        }
        
        embeds.append([
            "type": "photo",
            "url": url,
            "id": Int(Date().timeIntervalSince1970)
        ])
    }
}
