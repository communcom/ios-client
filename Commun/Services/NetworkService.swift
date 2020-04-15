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
