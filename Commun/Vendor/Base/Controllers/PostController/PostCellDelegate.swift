//
//  PostCellDelegate.swift
//  Commun
//
//  Created by Chung Tran on 11/29/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

protocol PostCellDelegate: class {
    func upvoteButtonDidTouch(post: ResponseAPIContentGetPost)
    func downvoteButtonDidTouch(post: ResponseAPIContentGetPost)
}

extension PostCellDelegate where Self: BaseViewController {
    func upvoteButtonDidTouch(post: ResponseAPIContentGetPost){
        
    }
    
    func downvoteButtonDidTouch(post: ResponseAPIContentGetPost) {
        
    }
}
