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

class NetworkService: NSObject {
    // MARK: - Properties
    static let shared = NetworkService()
    
    
    // MARK: - Class Functions
//    func connect() {
//        WebSocketManager.instance.connect()
//    }
//    
//    func disconnect() {
//        WebSocketManager.instance.disconnect()
//    }
    
    func loadFeed(_ paginationKey: String?, withSortType sortType: FeedTimeFrameMode = .all, withFeedType type: FeedSortMode = .popular, withFeedTypeMode typeMode: FeedTypeMode = .community) -> Observable<ResponseAPIContentGetFeed> {
        
        return Observable.create({ observer -> Disposable in
            
            RestAPIManager.instance.loadFeed(typeMode: typeMode,
                                             userID: Config.currentUser.nickName,
                                             communityID: "gls",
                                             timeFrameMode: sortType,
                                             sortMode: type,
                                             paginationSequenceKey: paginationKey,
                                             completion: { (feed, errorAPI) in
                                                guard errorAPI == nil else {
                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
                                                    observer.onError(errorAPI!)
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
    
    func getUserComments(_ paginationKey: String? = nil) -> Single<ResponseAPIContentGetComments> {
        return Single.create {single in
            RestAPIManager.instance.loadUserComments(paginationSequenceKey: paginationKey, completion: { (response, error) in
                guard error == nil else {
                    Logger.log(message: error!.caseInfo.message.localized(), event: .error)
                    single(.error(error!))
                    return
                }
                if let res = response {
                    single(.success(res))
                    return
                }
            })
            return Disposables.create()
        }
    }
    
    func getPostComment(_ paginationKey: String? = nil, withPermLink permLink: String, withRefBlock block: UInt64, forUser user: String) -> Single<ResponseAPIContentGetComments> {
        return Single.create{ single in
            RestAPIManager.instance.loadPostComments(nickName:                  user,
                                                     permlink:                  permLink,
                                                     refBlockNum:               block,
                                                     paginationSequenceKey:     paginationKey,
                                                     completion:                { (response, error) in
                                                        guard error == nil else {
                                                            Logger.log(message: error!.caseInfo.message.localized(), event: .error)
                                                            single(.error(error!))
                                                            return
                                                        }
                                                        
                                                        if let res = response {
                                                            single(.success(res))
                                                            return
                                                        }
            })
            return Disposables.create()
        }
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
    
    func voteMessage(voteType: VoteType, messagePermlink: String, messageAuthor: String, refBlockNum: UInt64) -> Completable {
        return Completable.create {completable in
            RestAPIManager.instance.message(voteType:        voteType,
                                            author:          messageAuthor,
                                            permlink:        messagePermlink,
                                            weight:          voteType == .unvote ? 0 : 10_000,
                                            refBlockNum:     refBlockNum,
                                            completion:      { (response, error) in
                                                
                                                guard error == nil else {
                                                    completable(.error(error!))
                                                    return
                                                }
                                                
                                                if response!.success {
                                                    completable(.completed)
                                                    return
                                                }
                                                
                                                completable(.error(ErrorAPI.requestFailed(message: "Unknown Error")))
            })
            return Disposables.create()
        }
    }
    
    func sendPost(withTitle title: String, withText text: String, metaData json: String, withTags tags: [String]) -> Observable<Bool> {
        return Observable<Bool>.create { observer -> Disposable in
//            RestAPIManager.instance.publish(message:        text,
//                                            headline:       title,
//                                            tags:           tags,
//                                            metaData:       json,
//                                            completion:     { (response, error) in
//                                                guard error == nil else {
//                                                    print(error!.caseInfo.message)
//                                                    return
//                                                }
//                                                
//                                                if let resp = response {
//                                                    print(resp.statusCode)
//                                                    print(resp.success)
//                                                    print(resp.body!)
//                                                    observer.onNext(resp.success)
//                                                }
//                                                observer.onCompleted()
//            })
            
            return Disposables.create()
        }
    }
    
    func signUp(withPhone phone: String) -> Observable<ResponseAPIRegistrationFirstStep> {
        return Observable.create({ observer -> Disposable in
//            RestAPIManager.instance.firstStep(phone:        phone,
//                                              completion:   { (result, error) in
//                                                guard error == nil else {
//                                                    Logger.log(message: error!.message.localized(), event: .error)
//                                                    
//                                                    if let state = error?.currentState {
//                                                        observer.onNext(ResponseAPIRegistrationFirstStep(code: UInt64(error!.code), strategy: state, nextSmsRetry: ""))
//                                                        observer.onCompleted()
//                                                    }
//                                                    
//                                                    return
//                                                }
// 
//                                                if let result = result {
//                                                    Logger.log(message: "Response: \n\t\(result)", event: .debug)
//                                                    observer.onNext(result)
//                                                }
//                                                
//                                                observer.onCompleted()
//            })
            
            return Disposables.create()
        })
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
    
    func setUser(name: String, phone: String) -> Observable<String> {
        return Observable.create({ observer -> Disposable in
//
//            let isDebugMode: Bool   =   appBuildConfig == AppBuildConfig.debug
//
//            RestAPIManager.instance.setUser(name:           name,
//                                            phone:          phone,
//                                            isDebugMode:    isDebugMode,
//                                            completion:     { (result, errorAPI) in
//                                                guard errorAPI == nil else {
//                                                    Logger.log(message: errorAPI!.caseInfo.message.localized(), event: .error)
//                                                    return
//                                                }
//
//                                                if let result = result {
//                                                    Logger.log(message: "Response: \n\t\(result.status)", event: .debug)
//                                                    observer.onNext(result.status)
//                                                }
//
//                                                observer.onCompleted()
//            })
            
            return Disposables.create()
        })
    }
    
    func saveKeys(nickName: String) -> Observable<Bool> {
        return Observable.create({ observer -> Disposable in
            RestAPIManager.instance.toBlockChain(nickName:          nickName,
                                                 phone:             UserDefaults.standard.value(forKey: Config.registrationUserPhoneKey) as? String ?? "",
                                                 responseHandling:  { result in
                                                    Logger.log(message: "Response: \n\t\(result.description)", event: .debug)
                                                    observer.onNext(result)
                                                    observer.onCompleted()
            },
                                                 errorHandling:     { errorAPI in
                                                    Logger.log(message: errorAPI.caseInfo.message.localized(), event: .error)
            })
            
            return Disposables.create()
        })
    }
    
    
    func getUserProfile() -> Single<ResponseAPIContentGetProfile> {
        return Single<ResponseAPIContentGetProfile>.create { single in
            guard let userNickName = Config.currentUser.nickName else { return Disposables.create() }
            
            RestAPIManager.instance.getProfile(nickName: userNickName,
                                               completion: { (response, error) in
                                                guard error == nil else {
                                                    single(.error(error!))
                                                    return
                                                }
                                                
                                                if let res = response {
                                                    single(.success(res))
                                                    return
                                                }
            })
            return Disposables.create()
        }
    }
    
    func getNotifications(fromId: String? = nil, markAsViewed: Bool = true, freshOnly: Bool = false) -> Single<ResponseAPIOnlineNotifyHistory> {
        return Single<ResponseAPIOnlineNotifyHistory>.create {single in
            RestAPIManager.instance.getOnlineNotifyHistory(fromId: fromId, freshOnly: false, completion: { (response, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                if let res = response {
                    single(.success(res))
                    return
                }
            })
            return Disposables.create()
        }
    }
    
    func getFreshNotifications() -> Single<ResponseAPIOnlineNotifyHistoryFresh> {
        return Single<ResponseAPIOnlineNotifyHistoryFresh>.create {single in
            RestAPIManager.instance.getOnlineNotifyHistoryFresh(completion: { (response, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                if let res = response {
                    single(.success(res))
                    return
                }
            })
            return Disposables.create()
        }
    }
    
    func markAllAsViewed() -> Single<ResponseAPINotifyMarkAllAsViewed> {
        return Single<ResponseAPINotifyMarkAllAsViewed>.create {single in
            RestAPIManager.instance.notifyMarkAllAsViewed(completion: { (response, error) in
                guard error == nil else {
                    single(.error(error!))
                    return
                }
                if let res = response {
                    single(.success(res))
                    return
                }
            })
            return Disposables.create()
        }
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
            let imgData = image.jpegData(compressionQuality: 1)!
            
            Alamofire.upload(multipartFormData: { (data) in
                data.append(imgData, withName: "file", fileName: "file.jpeg", mimeType: "image/jpeg")
            }, to: "https://img.golos.io/upload", encodingCompletion: { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON(completionHandler: { (response) in
                        switch response.result {
                        case .success(let value):
                            guard let json = value as? [String: Any],
                                let url = json["url"] as? String else {
                                    Logger.log(message: "Upload failed: \(String(describing: response.result))", event: .error)
                                    return single(.error(ErrorAPI.requestFailed(message: "upload failed")))
                            }
                            single(.success(url))
                            break
                        case .failure(let error):
                            Logger.log(message: error.localizedDescription, event: .error)
                            single(.error(error))
                            break
                        }
                    })
                    
                case .failure(let encodingError):
                    single(.error(encodingError))
                }
            })
            
            return Disposables.create()
        }
    }
    
    //  Update updatemeta
    func updateMeta(params: [String: String]) -> Completable {
        return .create {completable in
            RestAPIManager.instance.update(userProfile: params, responseHandling: { (_) in
                completable(.completed)
            }, errorHandling: { (error) in
                completable(.error(error))
            })
            return Disposables.create()
        }
    }
    
    // MARK: - options
    func getOptions() -> Completable {
        return .create {completable in
            RestAPIManager.instance.getOptions(responseHandling: { (options) in
                NotificationSettingType.getOptions(options.notify.show)
                completable(.completed)
            }, errorHandling: { (errorAPI) in
                completable(.error(errorAPI))
            })
            return Disposables.create()
        }
    }
    
    func setBasicOptions(lang: Language) {
        RestAPIManager.instance.setBasicOptions(language: lang.code, nsfwContent: .alwaysAlert, responseHandling: { (result) in

        }) { (errorAPI) in
        }
    }
    
    func setOptions(options: RequestParameterAPI.NoticeOptions, type: NoticeType) -> Completable {
        return .create {completable in
            RestAPIManager.instance.set(options: options, type: type, responseHandling: { (_) in
                completable(.completed)
            }, errorHandling: { (error) in
                completable(.error(error))
            })
            return Disposables.create()
        }
    }
}
