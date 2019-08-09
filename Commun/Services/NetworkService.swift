//
//  NetworkService.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import RxSwift
import Foundation
import Alamofire
import CyberSwift
import SwifterSwift
import eosswift

class NetworkService: NSObject {
    // MARK: - Properties
    static let shared = NetworkService()
    
    // MARK: - Helpers
    private func saveUserAvatarUrl(_ url: String) {
        if UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey) == url {
            return
        }
        UserDefaults.standard.set(url, forKey: Config.currentUserAvatarUrlKey)
    }
    
    // MARK: - Methods API
    func loadFeed(_ paginationKey: String?, withSortType sortType: FeedTimeFrameMode = .all, withFeedType type: FeedSortMode = .popular, withFeedTypeMode typeMode: FeedTypeMode = .community, userId: String? = nil) -> Single<ResponseAPIContentGetFeed> {
        
        return RestAPIManager.instance.loadFeed(typeMode: typeMode,
                                             userID: userId ?? Config.currentUser?.id,
                                             communityID:               AppProfileType.golos.rawValue,
                                             timeFrameMode:             sortType,
                                             sortMode:                  type,
                                             paginationSequenceKey:     paginationKey)
        
    }
    
    func getPost(withPermLink permLink: String, forUser user: String) -> Single<ResponseAPIContentGetPost> {
        return RestAPIManager.instance.loadPost(userID:        user,
                                             permlink:      permLink)
    }
    
    func deletePost(permlink: String) -> Completable {
        return RestAPIManager.instance.rx.deleteMessage(permlink: permlink)
            .observeOn(MainScheduler.instance)
    }
    
    func getUserComments(_ paginationKey: String? = nil, nickName: String? = nil) -> Single<ResponseAPIContentGetComments> {
        return RestAPIManager.instance.loadUserComments(
            nickName:               nickName,
            paginationLimit:        30,
            paginationSequenceKey:  paginationKey)
    }
    
    func getPostComment(_ paginationKey: String? = nil, withPermLink permLink: String, forUser user: String) -> Single<ResponseAPIContentGetComments> {
        return RestAPIManager.instance.loadPostComments(
            nickName:               user,
            permlink:               permLink,
            paginationLimit:        30,
            paginationSequenceKey:  paginationKey)
    }
    
    func voteMessage(voteType: VoteActionType, messagePermlink: String, messageAuthor: String) -> Completable {
        return RestAPIManager.instance.rx.vote(
                voteType:   voteType,
                author:     messageAuthor,
                permlink:   messagePermlink,
                weight:     voteType == .unvote ? 0 : 1)
            .observeOn(MainScheduler.instance)
    }
    
    // return transactionId
    func sendPost(withTitle title: String, withText text: String, metaData json: String, withTags tags: [String]) -> Single<SendPostCompletion> {
        return RestAPIManager.instance.rx.create(message:       text,
                                                 headline:      title,
                                                 author:        Config.currentUser?.id ?? "Commun",
                                                 tags:          tags,
                                                 metaData:      json)
            .observeOn(MainScheduler.instance)
    }
    
    func editPostWithPermlink(_ permlink: String, title: String, text: String, metaData json: String, withTags tags: [String])  -> Single<SendPostCompletion> {
        return RestAPIManager.instance.rx.updateMessage(
                permlink:       permlink,
                parentPermlink: nil,
                headline:       title,
                message:        text,
                tags:           tags,
                metaData:       json
            )
            .observeOn(MainScheduler.instance)
    }
    
    func waitForTransactionWith(id: String) -> Completable {
        return RestAPIManager.instance.waitForTransactionWith(id: id)
    }
    
    func sendComment(withMessage comment: String, parentAuthor: String, parentPermlink: String, metaData: String = "", tags: [String]) -> Completable {
        return RestAPIManager.instance.rx.create(message:           comment,
                                                 parentPermlink:    parentPermlink,
                                                 author:            parentAuthor,
                                                 tags:              tags,
                                                 metaData:          metaData
            )
            .flatMapCompletable({ (msgInfo) -> Completable in
                #warning("Remove this chaining to use socket in production")
                
                return self.waitForTransactionWith(id: msgInfo.transactionId!)
            })
            .observeOn(MainScheduler.instance)
    }
    
//    func resendSmsCode(phone: String) -> Observable<String> {
//        return Observable<String>.create({ observer -> Disposable in
//            let isDebugMode: Bool   =   appBuildConfig == AppBuildConfig.debug
//            
//            RestAPIManager.instance.resendSmsCode(phone:        phone,
//                                                  isDebugMode:  isDebugMode,
//                                                  completion:   { (result, errorAPI) in
//                                                    guard errorAPI == nil else {
//                                                        Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
//                                                        return
//                                                    }
//                                                    
//                                                    if let result = result {
//                                                        Logger.log(message: "Response: \n\t\(result.code)", event: .debug)
//                                                        observer.onNext("\(result.code )")
//                                                    }
//                                                    observer.onCompleted()
//            })
//            return Disposables.create()
//        }).map({ code -> String in
//            return code.md5() ?? ""
//        })
//    }
    
    
    func getUserProfile(userId: String? = nil) -> Single<ResponseAPIContentGetProfile> {
        guard let userNickName = userId ?? Config.currentUser?.id else { return .error(ErrorAPI.requestFailed(message: "userId missing")) }
        
        return RestAPIManager.instance.getProfile(userID: userNickName)
            .do(onSuccess: { (profile) in
                if userId == nil, let avatarUrl = profile.personal.avatarUrl {
                    self.saveUserAvatarUrl(avatarUrl)
                }
            })
    }
    
    func userVerify(phone: String, code: String) -> Observable<Bool> {
        
        return Observable<String>.create({ observer -> Disposable in
            
//            let isDebugMode: Bool   =   appBuildConfig == AppBuildConfig.debug
//            
//            RestAPIManager.instance.verify(phone:           phone,
//                                           code:            code,
//                                           isDebugMode:     isDebugMode,
//                                           completion:      { (result, errorAPI) in
//                                            guard errorAPI == nil else {
//                                                Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
//                                                return
//                                            }
//                                            
//                                            if let result = result {
//                                                Logger.log(message: "Response: \n\t\(result.status)", event: .debug)
//                                                observer.onNext(result.status)
//                                            }
//                                            
//                                            observer.onCompleted()
//            })
            
            return Disposables.create()
        }).map({ result -> Bool in
            return result == "OK"
        })
        
    }
    
    //  MARK: - Contract `gls.social`
    func uploadImage(_ image: UIImage) -> Single<String> {
        return .create {single in
            DispatchQueue(label: "Uploading queue").async {
                RestAPIManager.instance.posting(image: image, responseHandling: { (url) in
                    return single(.success(url))
                }, errorHandling: { (error) in
                    return single(.error(error))
                })
            }
            
            return Disposables.create()
        }
    }
    
    //  Update updatemeta
    func updateMeta(params: [String: String], waitForTransaction: Bool = true) -> Completable {
        return RestAPIManager.instance.rx.update(userProfile: params)
            .flatMapCompletable({ (transaction) -> Completable in
                // update profile
                if let url = params["profile_image"] {
                    self.saveUserAvatarUrl(url)
                }
                
                if !waitForTransaction {return .empty()}
                
                return self.waitForTransactionWith(id: transaction)
            })
            .observeOn(MainScheduler.instance)
    }
    
    func triggerFollow(_ userToFollow: String, isUnfollow: Bool = false) -> Completable {
        return RestAPIManager.instance.rx.follow(userToFollow, isUnfollow: isUnfollow)
            .flatMapCompletable { self.waitForTransactionWith(id: $0) }
    }
    
    // MARK: - meta
    // meta.recordPostView
    func markPostAsRead(permlink: String) -> Single<ResponseAPIMetaRecordPostView> {
        return RestAPIManager.instance.recordPostView(permlink: permlink)
    }
    
    // MARK: - Notifications
    func getNotifications(fromId: String? = nil, markAsViewed: Bool = true, freshOnly: Bool = false) -> Single<ResponseAPIOnlineNotifyHistory> {
        return RestAPIManager.instance.getOnlineNotifyHistory(fromId: fromId, freshOnly: false)
    }
    
    func getFreshNotifications() -> Single<ResponseAPIOnlineNotifyHistoryFresh> {
        return RestAPIManager.instance.getOnlineNotifyHistoryFresh()
    }
    
    func markAllAsViewed() -> Single<ResponseAPINotifyMarkAllAsViewed> {
        return RestAPIManager.instance.notifyMarkAllAsViewed()
    }
    
    func markAsRead(ids: [String]) -> Completable {
        if ids.isEmpty {return .empty()}
        return RestAPIManager.instance.markAsRead(notifies: ids)
            .flatMapToCompletable()
    }
}
