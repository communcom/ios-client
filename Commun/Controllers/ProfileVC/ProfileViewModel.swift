//
//  ProfileViewModel.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxDataSources

class ProfileViewModel {
    // MARK: - Properties
    let postsVM = PostsViewModel(
        filter: PostsFetcher.Filter(
            feedTypeMode: .byUser,
            feedType: .timeDesc,
            sortType: .all))
    
}
