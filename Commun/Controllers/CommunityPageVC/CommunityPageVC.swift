//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import CyberSwift

class CommunityPageVC: ProfileVC<ResponseAPIContentGetCommunity>, LeaderCellDelegate, PostCellDelegate {
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
    var communityId: String?
    var communityAlias: String?
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>!
    
    override func createViewModel() -> ProfileViewModel<ResponseAPIContentGetCommunity> {
        if let alias = communityAlias {
            return CommunityPageViewModel(communityAlias: alias)
        }
        return CommunityPageViewModel(communityId: communityId)
    }
    
    // MARK: - Subviews
    lazy var headerView = CommunityHeaderView(tableView: tableView)
    
    override var _headerView: ProfileHeaderView! {
        return headerView
    }
    
    lazy var postSortingView: UIView = {
        let feedTypeLabel = UILabel(forAutoLayout: ())
        feedTypeLabel.tag = 1
        
        let view = UIView(forAutoLayout: ())
        view.addSubview(feedTypeLabel)
        feedTypeLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .trailing)
        
        let arrow = UIImageView(width: 10, height: 6, imageNamed: "drop-down")
        view.addSubview(arrow)
        arrow.autoPinEdge(.leading, to: .trailing, of: feedTypeLabel, withOffset: 6)
        arrow.autoAlignAxis(toSuperviewAxis: .horizontal)
        arrow.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        
        view.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openFilterVC))
        view.addGestureRecognizer(tap)
        
        let containerView = UIView(frame: .zero)
        containerView.backgroundColor = .white
        containerView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0), excludingEdge: .trailing)
        
        let separator = UIView(height: 2, backgroundColor: .appLightGrayColor)
        containerView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        return containerView
    }()
    
    // MARK: - Initializers
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
    }
    
    init(communityAlias: String) {
        self.communityAlias = communityAlias
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func setUpTableView() -> UITableView {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }
    
    override func bind() {
        super.bind()
       
        bindSelectedIndex()
        
        // forward delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
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
        headerView.walletButton.addTarget(self, action: #selector(getPointsButtonTapped), for: .touchUpInside)
        
        (viewModel as! CommunityPageViewModel).walletGetBuyPriceRequest
            .subscribe(onSuccess: { (buyPrice) in
                self.headerView.setUp(walletPrice: buyPrice)
            }, onError: { (error) in
                self.showError(error)
            })
            .disposed(by: disposeBag)
    }
    
    override func handleListLoading() {
        switch (viewModel as! CommunityPageViewModel).segmentedItem.value {
        case .posts:
            tableView.addPostLoadingFooterView()
        case .leads:
            tableView.addNotificationsLoadingFooterView()
        default:
            break
        }
    }
    
    override func handleListEnded() {
        tableView.tableFooterView = UIView()
    }
    
    override func handleListEmpty() {
        var title = "empty"
        var description = "not found"
        
        switch (viewModel as! CommunityPageViewModel).segmentedItem.value {
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
    
    override func bindProfile() {
        super.bindProfile()
        
        bindProfileBlocked()
        
        ResponseAPIContentGetCommunity.observeItemChanged()
            .filter {$0.identity == self.viewModel.profile.value?.identity}
            .subscribe(onNext: {newCommunity in
                let community = self.viewModel.profile.value?.newUpdatedItem(from: newCommunity)
                self.viewModel.profile.accept(community)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindItems() {
        dataSource = MyRxTableViewSectionedAnimatedDataSource<AnimatableSectionModel<String, CustomElementType>>(
            configureCell: { (_, tableView, indexPath, element) -> UITableViewCell in
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
                case .leader(let leader):
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
                    cell.setUp(with: leader)
                    cell.delegate = self
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
        
        dataSource.animationConfiguration = AnimationConfiguration(reloadAnimation: .none)
        
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
            .map {items -> [AnimatableSectionModel<String, CustomElementType>] in
                if (self.viewModel as! CommunityPageViewModel).segmentedItem.value == .leads {
                    var leaders = [CustomElementType]()
                    var nominees = [CustomElementType]()
                    
                    for item in items {
                        switch item {
                        case .leader(let leader):
                            if leader.inTop {
                                leaders.append(.leader(leader))
                            } else {
                                nominees.append(.leader(leader))
                            }
                        default:
                            break
                        }
                    }
                    return [
                        AnimatableSectionModel<String, CustomElementType>(model: "leaders", items: leaders),
                        AnimatableSectionModel<String, CustomElementType>(model: "nominees", items: nominees)
                    ]
                }
                return [AnimatableSectionModel<String, CustomElementType>(model: "", items: items)]
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func cellSelected(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case is PostCell:
            let post = (viewModel as! CommunityPageViewModel).postsVM.items.value[indexPath.row]
            let postPageVC = PostPageVC(post: post)
            self.show(postPageVC, sender: nil)
        case is CommunityLeaderCell:
            //TODO: Tap a leaderCell
            break
        default:
            break
        }
    }
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        guard let profile = viewModel.profile.value else {return}
        let headerView = UIView(height: 40)
        
        let avatarImageView = MyAvatarImageView(size: 40)
        avatarImageView.setAvatar(urlString: profile.avatarUrl, namePlaceHolder: profile.name)
        headerView.addSubview(avatarImageView)
        avatarImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .trailing)
        
        let userNameLabel = UILabel.with(text: profile.name, textSize: 15, weight: .semibold)
        headerView.addSubview(userNameLabel)
        userNameLabel.autoPinEdge(toSuperviewEdge: .top)
        userNameLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userNameLabel.autoPinEdge(toSuperviewEdge: .trailing)

        let userIdLabel = UILabel.with(text: profile.communityId, textSize: 12, textColor: .appMainColor)
        headerView.addSubview(userIdLabel)
        userIdLabel.autoPinEdge(.top, to: .bottom, of: userNameLabel, withOffset: 3)
        userIdLabel.autoPinEdge(.leading, to: .trailing, of: avatarImageView, withOffset: 10)
        userIdLabel.autoPinEdge(toSuperviewEdge: .trailing)
        
        showCommunActionSheet(headerView: headerView, actions: [
            CommunActionSheet.Action(title: (profile.isInBlacklist == true ? "unhide": "hide").localized().uppercaseFirst, icon: UIImage(named: "profile_options_blacklist"), handle: {
                
                self.showAlert(
                    title: (profile.isInBlacklist == true ? "unhide community": "hide community").localized().uppercaseFirst,
                    message: (profile.isInBlacklist == true ? "do you really want to unhide all posts of": "do you really want to hide all posts of").localized().uppercaseFirst + " " + profile.name + "?",
                    buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                    highlightedButtonIndex: 1) { (index) in
                        if index != 0 {return}
                        if profile.isInBlacklist == true {
                            self.unhideCommunity()
                        } else {
                            self.hideCommunity()
                        }
                    }
            }, tintColor: profile.isInBlacklist == true ? .black: .ed2c5b)
        ]) {
            
        }
    }
}

// MARK: - UITableViewDelegate
extension CommunityPageVC: UITableViewDelegate {
    // MARK: - Sorting
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let viewModel = self.viewModel as! CommunityPageViewModel
        
        if viewModel.segmentedItem.value == .posts {
            return 48
        }
        
        if viewModel.segmentedItem.value == .leads {
            return 42
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewModel = self.viewModel as! CommunityPageViewModel
        if viewModel.segmentedItem.value == .posts {
            updatePostSortingView()
            return postSortingView
        }
        
        if viewModel.segmentedItem.value == .leads {
            let headerView = UIView(frame: .zero)
            
            let label = UILabel.with(text: dataSource.sectionModels[section].model.localized().uppercaseFirst, textSize: 17, weight: .semibold)
            headerView.addSubview(label)
            label.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
            label.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            return headerView
        }
        
        return nil
    }
    
    func updatePostSortingView() {
        let viewModel = self.viewModel as! CommunityPageViewModel
       
        if viewModel.segmentedItem.value != .posts {
            return
        }
        
        let filter = viewModel.postsVM.filter.value
        
        var feedTypeMode = filter.feedTypeMode
        
        if feedTypeMode == .community || feedTypeMode.localizedLabel == nil {
            feedTypeMode = .new
        }
        
        let aStr = NSMutableAttributedString()
            .semibold("sort".localized().uppercaseFirst + ":", color: .a5a7bd)
            .semibold(" ")
            .semibold(feedTypeMode.localizedLabel!.uppercaseFirst)
        
        if filter.feedTypeMode == .topLikes {
            aStr
                .semibold(", \(filter.sortType?.localizedLabel.uppercaseFirst ?? "")")
        }
        
        (postSortingView.viewWithTag(1) as! UILabel).attributedText = aStr
    }
    
    @objc func openFilterVC() {
        let viewModel = (self.viewModel as! CommunityPageViewModel).postsVM
        // Create FiltersVC
        var filter = viewModel.filter.value
        if filter.feedTypeMode == .community {filter.feedTypeMode = .new}
        let vc = PostsFilterVC(filter: filter)
        
        vc.completion = { filter in
            var filter = filter
            if filter.feedTypeMode == .new {
                filter.feedTypeMode = .community
            }
            viewModel.filter.accept(filter)
            self.updatePostSortingView()
        }
        
        let nc = BaseNavigationController(rootViewController: vc)
        nc.transitioningDelegate = vc
        nc.modalPresentationStyle = .custom
        
        present(nc, animated: true, completion: nil)
    }
    
    // MARK: - rowHeight caching
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return (viewModel as! CommunityPageViewModel).postsVM.rowHeights[post.identity] ?? UITableView.automaticDimension
        case let leader as ResponseAPIContentGetLeader:
            return (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] ?? UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            return (viewModel as! CommunityPageViewModel).postsVM.rowHeights[post.identity] ?? 200
        case let leader as ResponseAPIContentGetLeader:
            return (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] ?? 121
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case let post as ResponseAPIContentGetPost:
            (viewModel as! CommunityPageViewModel).postsVM.rowHeights[post.identity] = cell.bounds.height
        case let leader as ResponseAPIContentGetLeader:
            (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] = cell.bounds.height
        default:
            break
        }
    }
    
    // https://stackoverflow.com/questions/1074006/is-it-possible-to-disable-floating-headers-in-uitableview-with-uitableviewstylep
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView(frame: .zero)
    }
}
