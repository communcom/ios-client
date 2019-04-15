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
import SwifterSwift

class NetworkService: NSObject {
    
    static let shared = NetworkService()
    
    func connect() {
        WebSocketManager.instance.connect()
    }
    
    func disconnect() {
        WebSocketManager.instance.disconnect()
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
    
    enum SignInError: Error {
        case errorAPI(String)
    }
    
    func signIn(login: String, key: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in
            RestAPIManager.instance.authorize(userNickName: login, userActiveKey: key,
                                              completion: { (authAuthorize, errorAPI) in
                guard errorAPI == nil else {
                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                    observer.onError(SignInError.errorAPI(errorAPI!.caseInfo.message.localized()))
                    return
                }
                
                if let permission = authAuthorize?.permission {
                    Config.currentUser.nickName = login
                    Config.currentUser.activeKey = key
                    observer.onNext(permission)
                    Logger.log(message: permission, event: .debug)
                }
                observer.onCompleted()
            })
            
            return Disposables.create()
        })
    }
    
    func voteMessage(voteType: VoteType, messagePermlink: String, messageAuthor: String, refBlockNum: UInt64) {
        RestAPIManager.instance.message(voteType:        voteType,
                           author:          messageAuthor,
                           permlink:        messagePermlink,
                           weight:          voteType == .unvote ? 0 : 10_000,
                           refBlockNum:     refBlockNum,
                           completion:      { (response, error) in
                            
                            guard error == nil else {
                                print(error.debugDescription)
                                return
                            }
                            
                            print(response!.statusCode)
                            print(response!.success)
                            print(response!.body!)
        })
    }
    
    func sendPost(withTitle title: String, withText text: String, metaData json: String, withTags tags: [String]) -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in
            
            RestAPIManager.instance.publish(message:        text,
                                            headline:       title,
                                            tags:           tags,
                                            metaData:       json,
                                            completion:     { (response, error) in
                                                guard error == nil else {
                                                    print(error!.caseInfo.message)
                                                    return
                                                }
                                                
                                                if let resp = response {
                                                    print(resp.statusCode)
                                                    print(resp.success)
                                                    print(resp.body!)
                                                    observer.onNext(resp.success)
                                                }
                                                observer.onCompleted()
            })
            
            return Disposables.create()
        }
    }
    
    func signUp(withPhone phone: String) -> Observable<ResponseAPIRegistrationFirstStep> {
        return Observable.create({ observer -> Disposable in
            RestAPIManager.instance.firstStep(phone:        phone,
                                              completion:   { (result, errorAPI) in
                                                guard errorAPI == nil else {
                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                    return
                                                }
                                                
                                                if let result = result {
                                                    Logger.log(message: "Response: \n\t\(result)", event: .debug)
                                                    observer.onNext(result)
                                                }
                                                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
    
    func resendSmsCode(phone: String) -> Observable<String> {
        return Observable<String>.create({ observer -> Disposable in
            let isDebugMode: Bool   =   appBuildConfig == AppBuildConfig.debug
            
            RestAPIManager.instance.resendSmsCode(nickName:        phone,
                                                  isDebugMode:  isDebugMode,
                                                  completion:   { (result, errorAPI) in
                                                    guard errorAPI == nil else {
                                                        Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                        return
                                                    }
                                                    
                                                    if let result = result {
                                                        Logger.log(message: "Response: \n\t\(result.code)", event: .debug)
                                                        observer.onNext("\(result.code ?? 0)")
                                                    }
                                                    observer.onCompleted()
            })
            return Disposables.create()
        }).map({ code -> String in
            return code.md5() ?? ""
        })
    }
    
    func setUser(name: String, phone: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in
            
            let isDebugMode: Bool   =   appBuildConfig == AppBuildConfig.debug
            
            RestAPIManager.instance.setUser(name:           name,
                                            phone:          phone,
                                            isDebugMode:    isDebugMode,
                                            completion:     { (result, errorAPI) in
                                                guard errorAPI == nil else {
                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                    return
                                                }
                                                
                                                if let result = result {
                                                    Logger.log(message: "Response: \n\t\(result.status)", event: .debug)
                                                    observer.onNext(result.status)
                                                }
                                                
                                                observer.onCompleted()
            })
            
            return Disposables.create()
        })
    }
}
