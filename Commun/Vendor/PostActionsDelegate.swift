//
//  FeedPageVC+PostCardCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

protocol PostActionsDelegate {
    // Делагат еще буду дорабатывать по мере работы над информацией.
    func didTapMenuButton(forPost post: ResponseAPIContentGetPost)
    func didTapUpButton(forPost post: ResponseAPIContentGetPost)
    func didTapDownButton(forPost post: ResponseAPIContentGetPost)
    func didTapShareButton(forPost post: ResponseAPIContentGetPost)
}

extension PostActionsDelegate where Self: UIViewController {
    
    func didTapMenuButton(forPost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Нажата кнопка контекстного меню")
    }
    
    func didTapUpButton(forPost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Голос вверх")
        NetworkService.shared.voteMessage(voteType: .upvote,
                                          messagePermlink: post.contentId.permlink,
                                          messageAuthor: post.author?.username ?? "",
                                          refBlockNum: post.contentId.refBlockNum)
    }
    
    func didTapDownButton(forPost post: ResponseAPIContentGetPost) {
        showAlert(title: "TODO", message: "Голос вниз")
        NetworkService.shared.voteMessage(voteType: .downvote,
                                          messagePermlink: post.contentId.permlink,
                                          messageAuthor: post.author?.username ?? "",
                                          refBlockNum: post.contentId.refBlockNum)
    }
    
    func didTapShareButton(forPost post: ResponseAPIContentGetPost) {
        guard let userId = post.author?.userId else {return}
        // text to share
        let title = post.content.title
        
        #warning("refBlockNum is being removed")
        let link = "https://commun.com/posts/\(userId)/\(post.contentId.refBlockNum)/\(post.contentId.permlink)"
        
        
        // link to share
        let textToShare = [title, link]
        
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

}
