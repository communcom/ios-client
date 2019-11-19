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
import SDWebImage

class NetworkService: NSObject {
    // MARK: - Properties
    static let shared = NetworkService()
    
    // MARK: - Helpers
    private func saveUser(avatarUrl: String) {
        if UserDefaults.standard.string(forKey: Config.currentUserAvatarUrlKey) == avatarUrl {
            return
        }
        
        UserDefaults.standard.set(avatarUrl, forKey: Config.currentUserAvatarUrlKey)
    }

    private func saveUser(coverUrl: String) {
        if UserDefaults.standard.string(forKey: Config.currentUserCoverUrlKey) == coverUrl {
            return
        }
        
        UserDefaults.standard.set(coverUrl, forKey: Config.currentUserCoverUrlKey)
    }

    private func saveUser(biography: String) {
        if UserDefaults.standard.string(forKey: Config.currentUserBiographyKey) == biography {
            return
        }
        
        UserDefaults.standard.set(biography, forKey: Config.currentUserBiographyKey)
    }

    private func removeUserAvatar() {
        UserDefaults.standard.removeObject(forKey: Config.currentUserAvatarUrlKey)
    }

    private func removeUserCover() {
        UserDefaults.standard.removeObject(forKey: Config.currentUserCoverUrlKey)
    }

    private func removeUserBiography() {
        UserDefaults.standard.removeObject(forKey: Config.currentUserBiographyKey)
    }

    
    // MARK: - Methods API
//    func loadFeed(_ paginationKey: String?, withSortType sortType: FeedTimeFrameMode = .all, withFeedType type: FeedSortMode = .popular, withFeedTypeMode typeMode: FeedTypeMode = .community, userId: String? = nil) -> Single<ResponseAPIContentGetPosts> {
//        
//        return RestAPIManager.instance.loadFeed(typeMode: typeMode,
//                                             userID: userId ?? Config.currentUser?.id,
//                                             communityID:               AppProfileType.golos.rawValue,
//                                             timeFrameMode:             sortType,
//                                             sortMode:                  type,
//                                             paginationLimit:           20,
//                                             paginationSequenceKey:     paginationKey)
//        
//    }
    
    func deletePost(permlink: String) -> Completable {
        return RestAPIManager.instance.rx.deleteMessage(permlink: permlink)
            .observeOn(MainScheduler.instance)
    }
    
    func voteMessage(voteType: VoteActionType,
                     communityId: String,
                     messagePermlink: String,
                     messageAuthor: String) -> Completable {
        return RestAPIManager.instance.rx.vote(
                voteType:    voteType,
                communityId: communityId,
                author:      messageAuthor,
                permlink:    messagePermlink)
            .observeOn(MainScheduler.instance)
    }
    
    func waitForTransactionWith(id: String) -> Completable {
        return RestAPIManager.instance.waitForTransactionWith(id: id)
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
        // if userId = nil => retrieving current user
        guard let userNickName = userId ?? Config.currentUser?.id else { return .error(ErrorAPI.requestFailed(message: "userId missing")) }
        
        return RestAPIManager.instance.getProfile(user: userNickName)
            .do(onSuccess: { (profile) in
                if userId == Config.currentUser?.id {
                    // `personal.avatarUrl`
                    if let avatarUrlValue = profile.personal?.avatarUrl {
                        self.saveUser(avatarUrl: avatarUrlValue)
                    } else {
                        self.removeUserAvatar()
                    }

                    // `personal.coverUrl`
                    if let coverUrlValue = profile.personal?.coverUrl {
                        self.saveUser(coverUrl: coverUrlValue)
                    } else {
                        self.removeUserCover()
                    }

                    // `personal.biography`
                    if let biographyValue = profile.personal?.biography {
                        self.saveUser(biography: biographyValue)
                    } else {
                        self.removeUserBiography()
                    }
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
    
    func downloadImage(_ url: URL) -> Single<UIImage> {
        Logger.log(message: "Downloading image for \(url.absoluteString)", event: .debug)
        guard let imageDownloader = SDWebImageManager.shared().imageDownloader else {
            return .error(ErrorAPI.unknown)
        }
        return Single<UIImage>.create {single in
            imageDownloader.downloadImage(with: url) { (image, _, error, _) in
                if let image = image {
                    single(.success(image))
                    return
                }
                if let error = error {
                    single(.error(error))
                    return
                }
                single(.error(ErrorAPI.unknown))
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
                    self.saveUser(avatarUrl: url)
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
    
    // MARK: - Other
    func getEmbed(url: String) -> Single<ResponseAPIFrameGetEmbed> {
        return RestAPIManager.instance.getEmbed(url: url)
    }
}
