//
//  UserProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift

class UserProfilePageVC: ProfileVC<ResponseAPIContentGetProfile> {
    // MARK: - Properties
    let userId: String
    lazy var viewModel = UserProfilePageViewModel(profileId: userId)
    override var _viewModel: ProfileViewModel<ResponseAPIContentGetProfile> {
        return viewModel
    }
    
    // MARK: - Initializers
    init(userId: String) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func bind() {
        super.bind()
        
        headerView.selectedIndex
            .map { index -> UserProfilePageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .comments
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
            .disposed(by: disposeBag)
    }
    
    override func setUp(profile: ResponseAPIContentGetProfile) {
        super.setUp(profile: profile)
        // Register new cell type
        tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "CommentCell")
        
        // title
        title = profile.username ?? profile.userId
        
        // cover
        if let urlString = profile.personal.coverUrl
        {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        
    }
}
