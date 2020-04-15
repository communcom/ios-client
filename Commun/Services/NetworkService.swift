//
//  NetworkService.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import RxSwift
import Foundation
import CyberSwift
import SwifterSwift
import SDWebImage

class NetworkService: NSObject {
    // MARK: - Properties
    static let shared = NetworkService()
    
    // MARK: - Contract `gls.social`
    func downloadImage(_ url: URL) -> Single<UIImage> {
        Logger.log(message: "Downloading image for \(url.absoluteString)", event: .debug)
        return Single<UIImage>.create {single in
            SDWebImageManager.shared.loadImage(with: url, options: .highPriority, progress: nil) { (image, _, error, _, _, _) in
                if let image = image {
                   single(.success(image))
                   return
               }
               if let error = error {
                   single(.error(error))
                   return
               }
               single(.error(CMError.unknown))
            }
            return Disposables.create()
        }
    }
    
    func triggerFollow<T: ProfileType>(user: T) -> Completable {
        let originIsFollowing = user.isSubscribed ?? false
        let originIsInBlacklist = user.isInBlacklist ?? false
        
        // set value
        var user = user
        user.setIsSubscribed(!originIsFollowing)
        user.isInBlacklist = false
        user.isBeingToggledFollow = true
        
        // notify changes
        user.notifyChanged()
        
        // send request
        var request = BlockchainManager.instance.follow(user.userId, isUnfollow: originIsFollowing)
        
        if originIsInBlacklist
        {
            request = BlockchainManager.instance.unblock(user.userId)
                .flatMap {_ in BlockchainManager.instance.follow(user.userId)}
        }
        
        return request
            .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
            .do(onError: { (_) in
                // reverse change
                user.setIsSubscribed(originIsFollowing)
                user.isBeingToggledFollow = false
                user.isInBlacklist = originIsInBlacklist
                user.notifyChanged()
            }, onCompleted: {
                // re-enable state
                user.isBeingToggledFollow = false
                user.notifyChanged()
                
                if user.isSubscribed == false {
                    user.notifyEvent(eventName: ResponseAPIContentGetProfile.unfollowedEventName)
                } else {
                    user.notifyEvent(eventName: ResponseAPIContentGetProfile.followedEventName)
                }
            })
    }
    
    func triggerFollow(community: ResponseAPIContentGetCommunity) -> Completable {
        // for reverse
        let originIsFollowing = community.isSubscribed ?? false
        let originIsInBlacklist = community.isInBlacklist ?? false
        
        // set value
        var community = community
        community.setIsSubscribed(!originIsFollowing)
        community.isInBlacklist = false
        community.isBeingJoined = true
        
        // notify changes
        community.notifyChanged()
        
        let request: Single<String>
        
        if originIsInBlacklist {
            request = BlockchainManager.instance.unhideCommunity(community.communityId)
                .flatMap {_ in BlockchainManager.instance.follow(community.communityId)}
        } else if originIsFollowing {
            request = BlockchainManager.instance.unfollowCommunity(community.communityId)
        } else {
            request = BlockchainManager.instance.followCommunity(community.communityId)
        }
        
        return request
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .do(onError: { (_) in
                // reverse change
                community.setIsSubscribed(originIsFollowing)
                community.isBeingJoined = false
                community.isInBlacklist = originIsInBlacklist
                community.notifyChanged()
            }, onCompleted: {
                // re-enable state
                community.isBeingJoined = false
                community.notifyChanged()
                
                if community.isSubscribed == false {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.unfollowedEventName)
                } else {
                    community.notifyEvent(eventName: ResponseAPIContentGetCommunity.followedEventName)
                }
            })
    }
    
    func toggleVoteLeader(leader: ResponseAPIContentGetLeader) -> Completable {
        let originIsVoted = leader.isVoted ?? false
        
        // set value
        var leader = leader
        leader.setIsVoted(!originIsVoted)
        leader.isBeingVoted = true
        
        // notify change
        leader.notifyChanged()
        
        // send request
        let request: Single<String>
//        request = Single<String>.just("")
//            .delay(0.8, scheduler: MainScheduler.instance)
        if originIsVoted {
            // unvote
            request = BlockchainManager.instance.unvoteLeader(communityId: leader.communityId ?? "", leader: leader.userId)
        } else {
            request = BlockchainManager.instance.voteLeader(communityId: leader.communityId ?? "", leader: leader.userId)
        }
        
        return request
            .flatMapCompletable { RestAPIManager.instance.waitForTransactionWith(id: $0) }
            .do(onError: { (_) in
                // reverse change
                // re-enable state
                leader.setIsVoted(originIsVoted)
                leader.isBeingVoted = false
                leader.notifyChanged()
            }, onCompleted: {
                // re-enable state
                leader.isBeingVoted = false
                leader.notifyChanged()
            })
    }
}
