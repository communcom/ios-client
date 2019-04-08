//
//  FeedPageVC+PostCardCellDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 19/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC: PostCardCellDelegate {
    
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
        showAlert(title: "TODO", message: "Кнопка шары")
    }

}
