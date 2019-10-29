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
    
    // MARK: - Subviews
    var headerView: UserProfileHeaderView!
    override var _headerView: ProfileHeaderView! {
        return headerView
    }
    
    var communitiesCollectionView: UICollectionView {
        headerView.communitiesCollectionView
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
    override func setUp() {
        super.setUp()
        setHeaderView()
        headerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    func setHeaderView() {
        headerView = UserProfileHeaderView(tableView: tableView)
    }
    
    override func bind() {
        super.bind()
        bindSegmentedControl()
        
        bindCommunities()
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
        headerView.setUp(with: profile)
    }
    
    override func handleListLoading() {
        switch viewModel.segmentedItem.value {
        case .posts:
            tableView.addPostLoadingFooterView()
        case .comments:
            tableView.addNotificationsLoadingFooterView()
        }
    }
    
    override func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        switch viewModel.segmentedItem.value {
        case .posts:
            title = "no posts"
            description = "posts not found"
        case .comments:
            title = "no comments"
            description = "comments not found"
        }
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func createCell(for table: UITableView, index: Int, element: Any) -> UITableViewCell? {
        if let cell = super.createCell(for: table, index: index, element: element) {
            return cell
        }
        
       if let comment = element as? ResponseAPIContentGetComment {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
//            cell.delegate = self
            cell.setupFromComment(comment, expanded: true)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func cellSelected(_ indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath)
        switch cell {
        case is PostCell:
            if let postPageVC = controllerContainer.resolve(PostPageVC.self)
            {
                let post = self.viewModel.postsVM.items.value[indexPath.row]
                (postPageVC.viewModel as! PostPageViewModel).postForRequest = post
                self.show(postPageVC, sender: nil)
            } else {
                self.showAlert(title: "error".localized().uppercaseFirst, message: "something went wrong".localized().uppercaseFirst)
            }
            break
        case is CommentCell:
            #warning("Tap a comment")
            break
        default:
            break
        }
    }
}
