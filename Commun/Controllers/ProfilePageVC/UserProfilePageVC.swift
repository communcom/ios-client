//
//  UserProfilePageVC.swift
//  Commun
//
//  Created by Chung Tran on 10/28/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import CyberSwift
import RxDataSources

class UserProfilePageVC: ProfileVC<ResponseAPIContentGetProfile>, PostCellDelegate, CommentCellDelegate {
    
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
    var userName: String?

    lazy var expandedComments = [ResponseAPIContentGetComment]()
    override func createViewModel() -> ProfileViewModel<ResponseAPIContentGetProfile> {
        UserProfilePageViewModel(profileId: userId)
    }
    
    // MARK: - Subviews
    lazy var headerView = createHeaderView()
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
    func createHeaderView() -> UserProfileHeaderView {
        UserProfileHeaderView(tableView: tableView)
    }
    
    override func bind() {
        super.bind()
        bindSegmentedControl()
        
        bindCommunities()
        
        forwardDelegate()
        
        bindProfileBlocked()
    }
    
    override func setUp(profile: ResponseAPIContentGetProfile) {
        super.setUp(profile: profile)
        
        // Register new cell type
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        // title
        userName = profile.username

        // cover
        if let urlString = profile.coverUrl {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        headerView.setUp(with: profile)
    }
    
    override func handleListLoading() {
        switch (viewModel as! UserProfilePageViewModel).segmentedItem.value {
        case .posts:
            tableView.addPostLoadingFooterView()
        case .comments:
            tableView.addNotificationsLoadingFooterView()
        }
    }
    
    override func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    override func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        
        switch (viewModel as! UserProfilePageViewModel).segmentedItem.value {
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
            configureCell: { (_, tableView, _, element) -> UITableViewCell in
                switch element {
                case .post(let post):
                    switch post.document?.attributes?.type {
                    case "article":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                        cell.setUp(with: post)
                        cell.delegate = self
                        return cell
                    case "basic":
                        let cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                        cell.setUp(with: post)
                        cell.delegate = self
                        return cell
                    default:
                        break
                    }
                case .comment(let comment):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
                    cell.expanded = self.expandedComments.contains(where: {$0.identity == comment.identity})
                    cell.setUp(with: comment)
                    cell.delegate = self
                    return cell
                }
                return UITableViewCell()
            }
        )
        
        dataSource.animationConfiguration = AnimationConfiguration(reloadAnimation: .none)
        
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
            let post = (viewModel as! UserProfilePageViewModel).postsVM.items.value[indexPath.row]
            let postPageVC = PostPageVC(post: post)
            self.show(postPageVC, sender: nil)
        case is CommentCell:
            let comment = (viewModel as! UserProfilePageViewModel).commentsVM.items.value[indexPath.row]
            guard let userId = comment.parents.post?.userId,
                let permlink = comment.parents.post?.permlink,
                let communityId = comment.parents.post?.communityId
            else {
                return
            }
            let postPageVC = PostPageVC(userId: userId, permlink: permlink, communityId: communityId)
            self.show(postPageVC, sender: nil)
        default:
            break
        }
    }
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: viewModel.profile.value?.username, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.userId ?? "")", textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(style: .profile, headerView: headerView, actions: [
            CommunActionSheet.Action(title: "block".localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                
                self.showAlert(
                    title: "block user".localized().uppercaseFirst,
                    message: "do you really want to block".localized().uppercaseFirst + " \(self.viewModel.profile.value?.username ?? "this user")" + "?",
                    buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                    highlightedButtonIndex: 1) { (index) in
                        if index != 0 {return}
                        self.blockUser()
                    }
            })
        ]) {
            
        }
    }
}
