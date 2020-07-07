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
    let userId: String?
    var username: String?

    lazy var expandedComments = [ResponseAPIContentGetComment]()
    
    override func createViewModel() -> ProfileViewModel<ResponseAPIContentGetProfile> {
        UserProfilePageViewModel(userId: userId, username: username, authorizationRequired: authorizationRequired)
    }
    var commentsListViewModel: ListViewModel<ResponseAPIContentGetComment> {
        (viewModel as! UserProfilePageViewModel).commentsVM
    }
    var posts: [ResponseAPIContentGetPost] {
        let viewModel = self.viewModel as! UserProfilePageViewModel
        return viewModel.postsVM.items.value
    }
    
    // MARK: - Subviews
    lazy var headerView = createHeaderView()
    override var _headerView: ProfileHeaderView? {
        return headerView
    }
    
    var communitiesCollectionView: UICollectionView {
        headerView.communitiesCollectionView
    }
    
    // MARK: - Initializers
    init(userId: String?, username: String? = nil) {
        self.userId = userId
        self.username = username
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
    }
    
    override func bindProfile() {
        super.bindProfile()
        
        ResponseAPIContentGetProfile.observeItemChanged()
            .filter {$0.identity == self.viewModel.profile.value?.identity}
            .subscribe(onNext: { [weak self] (profile) in
                let profile = self?.viewModel.profile.value?.newUpdatedItem(from: profile)
                self?.viewModel.profile.accept(profile)
            })
            .disposed(by: disposeBag)
        
        ResponseAPIContentGetProfile.observeEvent(eventName: ResponseAPIContentGetProfile.blockedEventName)
            .subscribe(onNext: { (blockedProfile) in
                guard blockedProfile.userId == self.viewModel.profile.value?.userId else {return}
                self.back()
            })
            .disposed(by: disposeBag)
    }
    
    override func setUp(profile: ResponseAPIContentGetProfile) {
        super.setUp(profile: profile)
        
        // Register new cell type
        tableView.register(CommentCell.self, forCellReuseIdentifier: "CommentCell")
        
        // title
        username = profile.username

        // cover
        if let coverURL = profile.coverUrl, !coverURL.isEmpty {
            coverImageView.setImageDetectGif(with: coverURL)
            
            let imageViewTemp = UIImageView(frame: CGRect(origin: CGPoint(x: 0.0, y: -70.0), size: CGSize(width: UIScreen.main.bounds.width, height: 70.0)))
            imageViewTemp.backgroundColor = .clear
            imageViewTemp.addTapToViewer(with: coverURL)
            imageViewTemp.highlightedImage = coverImageView.image

            tableView.addSubview(imageViewTemp)
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
            title = String(format: "%@ %@", "no".localized().uppercaseFirst, "posts".localized().uppercaseFirst)
            description = String(format: "%@ %@ %@", "you haven’t created any".localized().uppercaseFirst, "posts".localized(), "yet".localized())

            tableView.addEmptyPlaceholderFooterView(title: title, description: description, buttonLabel: String(format: "%@ %@", "create".localized().uppercaseFirst, "post".localized())) {
                if let tabBarVC = self.tabBarController as? TabBarVC {
                    tabBarVC.buttonAddTapped()
                }
            }

        case .comments:
            title = String(format: "%@ %@", "no".localized().uppercaseFirst, "comments".localized().uppercaseFirst)
            description = String(format: "%@ %@ %@", "you haven’t written any".localized().uppercaseFirst, "comments".localized(), "yet".localized())

            tableView.addEmptyPlaceholderFooterView(title: title, description: description)
        }
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
                    cell.showIndentForChildComment = false
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
            .do(onNext: { (items) in
                if items.count == 0 {
                    self.handleListEmpty()
                }
            })
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
            postPageVC.selectedComment = comment
    
            self.show(postPageVC, sender: nil)
        default:
            break
        }
    }
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        guard let profile = viewModel.profile.value else { return }
        
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        
        avatarImageView
            .observeCurrentUserAvatar()
            .disposed(by: disposeBag)
       
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: profile.username, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(profile.userId)", textSize: 12, weight: .medium, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(headerView: headerView, actions: [
            CommunActionSheet.Action(title: "share".localized().uppercaseFirst,
                                     icon: UIImage(named: "icon-share-circle-white"),
                                     style: .share,
                                     marginTop: 0,
                                     handle: {
                                        ShareHelper.share(urlString: self.shareWith(name: profile.username, userID: profile.userId))
            }),
            CommunActionSheet.Action(title: profile.isInBlacklist == true ? "unblock".localized().uppercaseFirst: "block".localized().uppercaseFirst,
                                     icon: UIImage(named: "profile_options_blacklist"),
                                     style: .profile,
                                     marginTop: 15,
                                     handle: {
                                        self.showAlert(
                                            title: profile.isInBlacklist == true ? "unblock user".localized().uppercaseFirst: "block user".localized().uppercaseFirst,
                                            message: "do you really want to".localized().uppercaseFirst + " " + (profile.isInBlacklist == true ? "unblock".localized(): "block".localized()) + " \(self.viewModel.profile.value?.username ?? "this user")" + "?",
                                            buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                                            highlightedButtonIndex: 1) { (index) in
                                                if index != 0 { return }
                                                
                                                if profile.isInBlacklist == true {
                                                    self.unblockUser()
                                                } else {
                                                    self.blockUser()
                                                }
                                        }
            })
        ]) {
            
        }
    }
}
