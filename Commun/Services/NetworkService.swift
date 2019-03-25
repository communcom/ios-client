//
//  NetworkService.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxSwift

class NetworkService: NSObject {
    
    static let shared = NetworkService()
    
    func connect() {
        if !Config.webSocket.isConnected {
            Config.webSocket.connect()
            
            if Config.webSocket.delegate == nil {
                Config.webSocket.delegate = WebSocketManager.instance
            }
        }
    }
    
    func disconnect() {
        if Config.webSocket.isConnected {
            Config.webSocket.disconnect()
        }
    }
    
    func loadFeed(_ paginationKey: String?, withSortType sortType: FeedTimeFrameMode = .all, withFeedType type: FeedSortMode = .popular) -> Observable<ResponseAPIContentGetFeed> {
        
        return Observable.create({ observer -> Disposable in
            
            RestAPIManager.instance.loadFeed(userID: Config.currentUser.nickName,
                                             communityID: "gls",
                                             timeFrameMode: sortType,
                                             sortMode: type,
                                             paginationSequenceKey: paginationKey,
                                             completion: { (feed, errorAPI) in
                                                guard errorAPI == nil else {
                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                    //                        observer.onError(errorAPI!)
                                                    return
                                                }
                                                
                                                guard feed?.sequenceKey != nil else {
                                                    observer.onError(NSError(domain: "io.commun.eos.ios", code: 0, userInfo: nil))
                                                    Logger.log(message: "Feed is finished.", event: .error)
                                                    return
                                                }
                                                
                                                if let feed = feed {
                                                    Logger.log(message: "Response: \n\t\(feed.items ?? [])", event: .debug)
                                                    observer.onNext(feed)
                                                }
                                                observer.onCompleted()
            })
            
            
            return Disposables.create()
        })
        
    }
    
    func getPost(withPermLink permLink: String, withRefBlock block: UInt64, forUser user: String) -> Observable<ResponseAPIContentGetPost> {
        return Observable.create({ observer -> Disposable in
            
            RestAPIManager.instance.loadPost(userID:        user,
                                             permlink:      permLink,
                                             refBlockNum:   block,
                                             completion:    { (post, errorAPI) in
                                                guard errorAPI == nil else {
                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                    return
                                                }
                                                
                                                if let post = post {
                                                    Logger.log(message: "Response: \n\t\(post)", event: .debug)
                                                    observer.onNext(post)
                                                }
                                                
                                                observer.onCompleted()
            })
            
            return Disposables.create()
        })
    }
    
    func getUserComment() {
        RestAPIManager.instance.loadUserComments(nickName:      "tst3guarnodu",
                                                 completion:    { (comments, errorAPI) in
                                                    guard errorAPI == nil else {
                                                        Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                        return
                                                    }
                                                    
                                                    Logger.log(message: "Response: \n\t\(comments!)", event: .debug)
        })
    }
    
    func getPostComment(withPermLink permLink: String, withRefBlock block: UInt64, forUser user: String) -> Observable<ResponseAPIContentGetComments> {
        return Observable.create({ observer -> Disposable in
            RestAPIManager.instance.loadPostComments(nickName:                  user,
                                                     permlink:                  permLink,
                                                     refBlockNum:               block,
                                                     paginationSequenceKey:     nil,
                                                     completion:                { (comments, errorAPI) in
                                                        guard errorAPI == nil else {
                                                            Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                            return
                                                        }
                                                        
                                                        if let comments = comments {
                                                            Logger.log(message: "Response: \n\t\(comments)", event: .debug)
                                                            observer.onNext(comments)
                                                        }
                                                        observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
