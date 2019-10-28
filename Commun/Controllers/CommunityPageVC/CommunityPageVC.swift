//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommunityPageVC: ProfileVC {
    // MARK: - Properties
    let communityId: String
    lazy var viewModel: CommunityPageViewModel = CommunityPageViewModel(communityId: communityId)
    let disposeBag = DisposeBag()
    
    // MARK: - Initializers
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func bind() {
        super.bind()
        
        bindCommunity()
        
        bindList()
        
        bindControls()
    }
    
    func setUpWithCommunity(_ community: ResponseAPIContentGetCommunity) {
        // title
        title = community.name
        
        // cover
        if let urlString = community.coverUrl
        {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        headerView.setUp(with: community)
    }
}
