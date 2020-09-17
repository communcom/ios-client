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

class CommunityPageVC: ProfileVC<ResponseAPIContentGetCommunity>, LeaderCellDelegate, PostCellDelegate, CommunityPageVCType, HasLeadersVM {
    
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
    
    var community: ResponseAPIContentGetCommunity? {
        return viewModel.profile.value
    }
    
    var price: Double?
    
    override func createViewModel() -> ProfileViewModel<ResponseAPIContentGetCommunity> {
        if let alias = communityAlias {
            return CommunityPageViewModel(communityAlias: alias, authorizationRequired: authorizationRequired)
        }
        
        return CommunityPageViewModel(communityId: communityId, authorizationRequired: authorizationRequired)
    }
    var leadersVM: LeadersViewModel {(viewModel as! CommunityPageViewModel).leadsVM}
    var posts: [ResponseAPIContentGetPost] {(viewModel as! CommunityPageViewModel).postsVM.items.value}
    
    // MARK: - Subviews
    lazy var headerView = createHeaderView()
    func createHeaderView() -> CommunityHeaderView {
        CommunityHeaderView(tableView: tableView)
    }
    
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
        containerView.backgroundColor = .appWhiteColor
        containerView.addSubview(view)
        view.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0), excludingEdge: .trailing)
        
        let separator = UIView(height: 2, backgroundColor: .appLightGrayColor)
        containerView.addSubview(separator)
        separator.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        
        return containerView
    }()
    
    lazy var manageCommunityBarButton: UIButton = {
        let button = UIButton.settings(tintColor: .white)
        button.addTarget(self, action: #selector(showCommunityControlPanel), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(communityId: String) {
        self.communityId = communityId
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    init(communityAlias: String) {
        self.communityAlias = communityAlias
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        leadersVM.fetchNext()
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
        
        bindCommunityManager()
        
        // forward delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func setUp(profile: ResponseAPIContentGetCommunity) {
        super.setUp(profile: profile)
        
        if profile.isLeader == true {
            rightBarButtonsStackView.insertArrangedSubview(manageCommunityBarButton, at: 0)
        }
       
        // Register new cell type
        tableView.register(CommunityLeaderCell.self, forCellReuseIdentifier: "CommunityLeaderCell")
        tableView.register(CommunityAboutCell.self, forCellReuseIdentifier: "CommunityAboutCell")
        tableView.register(CommunityRuleCell.self, forCellReuseIdentifier: "CommunityRuleCell")
    
        // title
        title = profile.name
        
        // cover
        if let coverURL = profile.coverUrl {
            coverImageView.setImageDetectGif(with: coverURL)
            
            let imageViewTemp = UIImageView(frame: CGRect(origin: CGPoint(x: 0.0, y: -70.0), size: CGSize(width: UIScreen.main.bounds.width, height: 70.0)))
            imageViewTemp.backgroundColor = .clear
            imageViewTemp.addTapToViewer(with: coverURL)
            imageViewTemp.highlightedImage = coverImageView.image
            
            tableView.addSubview(imageViewTemp)
        }
        
        // header
        headerView.setUp(with: profile)
        headerView.walletView.nextButton.isUserInteractionEnabled = true
        headerView.walletView.nextButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(getPointsButtonTapped)))
        
        (viewModel as! CommunityPageViewModel).walletGetBuyPriceRequest
            .subscribe(onSuccess: { (buyPrice) in
                self.price = buyPrice.priceValue
                self.headerView.setUp(walletPrice: buyPrice)
            }, onError: { (error) in
                self.showError(error)
            })
            .disposed(by: disposeBag)
        
        // community manager
        if community?.isLeader == true {
            headerView.manageCommunityButtonsView.proposalsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(proposalsButtonDidTouch)))
            headerView.manageCommunityButtonsView.reportsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(reportsButtonDidTouch)))
            headerView.manageCommunityButtonsView.manageCommunityButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(manageCommunityDidTouch)))
        }
        
        // become a leader
        headerView.becomeALeaderButton.addTarget(self, action: #selector(becomeALeaderButtonDidTouch), for: .touchUpInside)
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
                    
                    var sections = [AnimatableSectionModel<String, CustomElementType>]()
                    if !leaders.isEmpty {sections.append(AnimatableSectionModel<String, CustomElementType>(model: "leaders", items: leaders))}
                    if !nominees.isEmpty {sections.append(AnimatableSectionModel<String, CustomElementType>(model: "nominees", items: nominees))}
                    
                    return sections
                }
                return [AnimatableSectionModel<String, CustomElementType>(model: "", items: items)]
            }
            .do(onNext: { (items) in
                if items.count == 0 {
                    self.handleListEmpty()
                }
            })
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
            break
        default:
            break
        }
    }
    
    override func moreActionsButtonDidTouch(_ sender: CommunButton) {
        guard let profile = viewModel.profile.value, let currentUserID = Config.currentUser?.id else {return}
        
        let headerView = CMMetaView(forAutoLayout: ())
        headerView.avatarImageView.setAvatar(urlString: profile.avatarUrl)
        headerView.titleLabel.text = profile.name
        headerView.subtitleLabel.text = profile.communityId
        
        showCMActionSheet(
            headerView: headerView,
            actions: [
                .default(
                    title: "share".localized().uppercaseFirst,
                    iconName: "share",
                    handle: {
                        ShareHelper.share(urlString: self.shareWith(name: profile.alias ?? "", userID: currentUserID, isCommunity: true))
                    }, bottomMargin: 10
                ),
                .default(
                    title: (profile.isInBlacklist == true ? "unhide": "hide").localized().uppercaseFirst,
                    iconName: "profile_options_blacklist",
                    handle: {
                        self.showAlert(
                            title: (profile.isInBlacklist == true ? "unhide community" : "hide community").localized().uppercaseFirst,
                            message: (profile.isInBlacklist == true ? "do you really want to unhide all posts of" : "do you really want to hide all posts of").localized().uppercaseFirst + " " + profile.name + "?",
                            buttonTitles: ["yes".localized().uppercaseFirst, "no".localized().uppercaseFirst],
                            highlightedButtonIndex: 1) { (index) in
                                if index != 0 {return}
                                if profile.isInBlacklist == true {
                                    self.unhideCommunity()
                                } else {
                                    self.hideCommunity()
                                }
                        }
                    })
            ]
        )
    }
    
    override func configureNavigationBar() {
        super.configureNavigationBar()
        manageCommunityBarButton.tintColor = showNavigationBar ? .appBlackColor: .white
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
        
        var type = filter.type
        
        if type == .community || type.localizedLabel == nil {
            type = .new
        }
        
        let aStr = NSMutableAttributedString()
            .semibold("sort".localized().uppercaseFirst + ":", color: .appGrayColor)
            .semibold(" ")
            .semibold(type.localizedLabel!.uppercaseFirst)
        
        if filter.type == .topLikes {
            aStr
                .semibold(", \(filter.timeframe?.localizedLabel.uppercaseFirst ?? "")")
        }
        
        (postSortingView.viewWithTag(1) as! UILabel).attributedText = aStr
    }
    
    @objc func openFilterVC() {
        let viewModel = (self.viewModel as! CommunityPageViewModel).postsVM
        // Create FiltersVC
        var filter = viewModel.filter.value
        if filter.type == .community {filter.type = .new}
        let vc = PostsFilterVC(filter: filter)
        
        vc.completion = { filter in
            var filter = filter
            if filter.type == .new {
                filter.type = .community
            }
            viewModel.filter.accept(filter)
            self.updatePostSortingView()
        }
        
        let nc = SwipeNavigationController(rootViewController: vc)
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
//        case let leader as ResponseAPIContentGetLeader:
//            return (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] ?? UITableView.automaticDimension
        case let rule as ResponseAPIContentGetCommunityRule:
            return UITableView.automaticDimension
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
//        case let leader as ResponseAPIContentGetLeader:
//            return (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] ?? 121
        case let rule as ResponseAPIContentGetCommunityRule:
            return (viewModel as! CommunityPageViewModel).ruleRowHeights[rule.identity] ?? 68
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let item = viewModel.items.value[safe: indexPath.row] else {
            return
        }
        
        switch item {
        case var post as ResponseAPIContentGetPost:
            (viewModel as! CommunityPageViewModel).postsVM.rowHeights[post.identity] = cell.bounds.height
            
            // record post view
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if tableView.isCellVisible(indexPath: indexPath) &&
                    (cell as! PostCell).post?.identity == post.identity &&
                    !RestAPIManager.instance.markedAsViewedPosts.contains(post.identity)
                {
                    post.markAsViewed().disposed(by: self.disposeBag)
                }
            }
            
            // hide donation buttons when cell was removed
            if !tableView.isCellVisible(indexPath: indexPath), post.showDonationButtons == true {
                post.showDonationButtons = false
                post.notifyChanged()
            }
        case let leader as ResponseAPIContentGetLeader:
            (viewModel as! CommunityPageViewModel).leadsVM.rowHeights[leader.identity] = cell.bounds.height
        case let rule as ResponseAPIContentGetCommunityRule:
            (viewModel as! CommunityPageViewModel).ruleRowHeights[rule.identity] = cell.bounds.height
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
