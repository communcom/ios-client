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
        case about(ResponseAPIContentGetProfile)
        
        var identity: String {
            switch self {
            case .post(let post):
                return post.identity
            case .comment(let comment):
                return comment.identity
            case .about(let profile):
                return profile.identity
            }
        }
    }
    
    // MARK: - Properties
    let userId: String?
    var username: String?
    
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
        tableView.register(UserProfileAboutCell.self, forCellReuseIdentifier: "AboutCell")
        
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
            
        case .about:
            tableView.tableFooterView = UIView()
        }
    }
    
    override func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    override func handleListEmpty() {
        var title = "empty"
        
        switch (viewModel as! UserProfilePageViewModel).segmentedItem.value {
        case .posts:
            title = "no posts".localized().uppercaseFirst
            tableView.addEmptyPlaceholderFooterView(title: title)

        case .comments:
            title = "no comments".localized().uppercaseFirst
            tableView.addEmptyPlaceholderFooterView(title: title)
            
        case .about:
            title = "no info".localized().uppercaseFirst
            tableView.addEmptyPlaceholderFooterView(title: title)
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
                    cell.showIndentForChildComment = false
                    cell.setUp(with: comment)
                    cell.delegate = self
                    return cell
                case .about(let profile):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "AboutCell") as! UserProfileAboutCell
                    cell.setUp(with: profile)
//                    cell.delegate = self
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
                    if let item = item as? ResponseAPIContentGetProfile {
                        return .about(item)
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
        
        let headerView = CMMetaView(forAutoLayout: ())
        headerView.avatarImageView.setAvatar(urlString: profile.avatarUrl)
        headerView.titleLabel.text = profile.personal?.fullName ?? profile.username
        headerView.subtitleLabel.text = "@\(profile.username ?? profile.userId)"
        headerView.subtitleLabel.textColor = .appMainColor
        
        showCMActionSheet(headerView: headerView, actions: actionsForMoreButton())
    }
    
    func actionsForMoreButton() -> [CMActionSheet.Action] {
        guard let profile = viewModel.profile.value else { return []}
        return [
            .iconFirst(
                title: "share".localized().uppercaseFirst,
                iconName: "icon-share-circle-white",
                handle: {
                    ShareHelper.share(urlString: self.shareWith(name: profile.username ?? "", userID: profile.userId))
                },
                bottomMargin: 15
            ),
            .iconFirst(
                title: profile.isInBlacklist == true ? "unblock".localized().uppercaseFirst: "block".localized().uppercaseFirst,
                iconName: "profile_options_blacklist",
                handle: {
                    self.confirmBlock()
                },
                showNextButton: true
            ),
        ]
    }
    
    func confirmBlock() {
        guard let profile = viewModel.profile.value else { return }
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
    }
}
