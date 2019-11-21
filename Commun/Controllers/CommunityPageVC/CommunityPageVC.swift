//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

class CommunityPageVC: ProfileVC<ResponseAPIContentGetCommunity>{
    // MARK: - Nested type
    enum CustomElementType: IdentifiableType, Equatable {
        case post(ResponseAPIContentGetPost)
        case leader(ResponseAPIContentGetLeader)
        case about(String)
        case rule(ResponseAPIContentGetCommunityRule)
        
        var identity: String {
            switch self {
            case .post(let post):
                return post.identity
            case .leader(let leader):
                return leader.identity
            case .about(let string):
                return string
            case .rule(let rule):
                return rule.identity
            }
        }
    }
    
    // MARK: - Properties
    let communityId: String

    lazy var viewModel: CommunityPageViewModel = CommunityPageViewModel(communityId: communityId)
    
    override var _viewModel: ProfileViewModel<ResponseAPIContentGetCommunity> {
        return viewModel
    }
    
    
    // MARK: - Subviews
    var headerView: CommunityHeaderView!
    override var _headerView: ProfileHeaderView! {
        return headerView
    }
    
    
    // MARK: - Initializers
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        
        headerView = CommunityHeaderView(tableView: tableView)
    }
    
    override func bind() {
        super.bind()
       
        bindSelectedIndex()
        bindProfileBlocked()
    }
    
    override func setUp(profile: ResponseAPIContentGetCommunity) {
        super.setUp(profile: profile)
       
        // Register new cell type
        tableView.register(CommunityLeaderCell.self, forCellReuseIdentifier: "CommunityLeaderCell")
        tableView.register(CommunityAboutCell.self, forCellReuseIdentifier: "CommunityAboutCell")
        tableView.register(CommunityRuleCell.self, forCellReuseIdentifier: "CommunityRuleCell")
    
        // title
        title = profile.name
        
        // cover
        if let urlString = profile.coverUrl {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        headerView.setUp(with: profile)
    }
    
    override func handleListLoading(isLoading: Bool) {
        if isLoading {
            switch viewModel.segmentedItem.value {
            case .posts:
                tableView.addPostLoadingFooterView()
            case .leads:
                tableView.addNotificationsLoadingFooterView()
            default:
                break
            }
        }
        else {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    override func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        
        switch viewModel.segmentedItem.value {
        case .posts:
            title = "no posts"
            description = "posts not found"
        case .leads:
            title = "no leaders"
            description = "leaders not found"
        case .rules:
            title = "no rules"
            description = "rules not found"
        case .about:
            title = "no description"
            description = "description not found"
        }
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func bindItems() {
        let dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>(
            configureCell: { (dataSource, tableView, indexPath, element) -> UITableViewCell in
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
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
                case .leader(let leader):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
                    cell.setUp(with: leader)
                    return cell
                case .about(let string):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityAboutCell") as! CommunityAboutCell
                    cell.label.text = string
                    return cell
                case .rule(let rule):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityRuleCell") as! CommunityRuleCell
                    cell.rowIndex = indexPath.row
                    cell.setUp(with: rule)
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
                    if let item = item as? ResponseAPIContentGetLeader {
                        return .leader(item)
                    }
                    if let item = item as? String {
                        return .about(item)
                    }
                    if let item = item as? ResponseAPIContentGetCommunityRule {
                        return .rule(item)
                    }
                    return nil
                }
            }
            .map {[AnimatableSectionModel<String, CustomElementType>(model: "", items: $0)]}
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func cellSelected(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case is PostCell:
            let post = self.viewModel.postsVM.items.value[indexPath.row]
            let postPageVC = PostPageVC(post: post)
            self.show(postPageVC, sender: nil)
            break
        case is CommunityLeaderCell:
            #warning("Tap a leaderCell")
            break
        default:
            break
        }
    }
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.setAvatar(urlString: viewModel.profile.value?.avatarUrl, namePlaceHolder: viewModel.profile.value?.name ?? "Community")
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: viewModel.profile.value?.name, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: "@\(viewModel.profile.value?.communityId ?? "")", textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(style: .profile, headerView: headerView, actions: [
            CommunActionSheet.Action(title: "hide".localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                
                self.showAlert(
                    title: "hide community".localized().uppercaseFirst,
                    message: "do you really want to hide all posts of".localized().uppercaseFirst + " \(self.viewModel.profile.value?.name ?? "this community")" + "?",
                    buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                    highlightedButtonIndex: 1) { (index) in
                        if index != 0 {return}
                        self.hideCommunity()
                    }
            })
        ]) {
            
        }
    }
}
