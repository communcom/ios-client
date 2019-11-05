//
//  UserProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

class UserProfilePageVC: ProfileVC<ResponseAPIContentGetProfile> {
    // MARK: - Nested type
    enum CustomElementType: IdentifiableType, Equatable {
        case post(ResponseAPIContentGetPost)
        case comment(ResponseAPIContentGetComment)
        
        var identity: String {
            switch self {
            case .post(let post):
                return post.identity
            case .comment(let comment):
                return comment.identity
            }
        }
    }
    
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
        title = profile.username
        
        // cover
        if let urlString = profile.personal?.coverUrl
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
    
    override func bindItems() {
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>(
            configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
                switch element {
                case .post(let post):
                    switch post.document?.attributes?.type {
                    case "article":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                        cell.setUp(with: post)
                        return cell
                    case "basic":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                        cell.setUp(with: post)
                        return cell
                    default:
                        break
                    }
                case .comment(let comment):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    //            cell.delegate = self
                    cell.setupFromComment(comment, expanded: false)
                    return cell
                }
                return UITableViewCell()
            }
        )
        
        viewModel.items
            .map { items in
                items.compactMap {item -> CustomElementType? in
                    if let item = item as? ResponseAPIContentGetPost {
                        return .post(item)
                    }
                    if let item = item as? ResponseAPIContentGetComment {
                        return .comment(item)
                    }
                    return nil
                }
            }
            .map {[AnimatableSectionModel<String, CustomElementType>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
