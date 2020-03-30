//
//  DiscoveryAllVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class DiscoveryAllVC: SubsViewController<ResponseAPIContentSearchItem, SubscribersCell>, CommunityCellDelegate, ProfileCellDelegate {
    override var shouldHideNavigationBar: Bool {true}
    
    // MARK: - Properties
    var seeAllHandler: ((Int) -> Void)?
    override var isInfiniteScrollingEnabled: Bool {false}
    override var listLoadingStateObservable: Observable<ListFetcherState> {
        let viewModel = self.viewModel as! DiscoveryAllViewModel
        let subscriptionsFetchingState = viewModel.subscriptionsFetcherState
        return Observable.merge(
            viewModel.state.filter {_ in !viewModel.isQueryEmpty},
            subscriptionsFetchingState.filter {_ in viewModel.isQueryEmpty}
        )
    }
    
    // MARK: - Initializers
    init(seeAllHandler: ((Int) -> Void)? = nil) {
        self.seeAllHandler = seeAllHandler
        let vm = DiscoveryAllViewModel()
        super.init(viewModel: vm)
        
        defer {
            showShadowWhenScrollUp = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods
    override func setUp() {
        super.setUp()
        refreshControl.subviews.first?.bounds.origin.y = -15
    }

    override func setUpTableView() {
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.configureForAutoLayout()
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
        
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        tableView.contentInset.top -= 14
    }
    
    override func bind() {
        super.bind()
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func registerCell() {
        super.registerCell()
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
    }
    
    override func configureCell(with item: ResponseAPIContentSearchItem, indexPath: IndexPath) -> UITableViewCell {
        if let community = item.communityValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as! CommunityCell
            cell.setUp(with: community)
            cell.delegate = self

            cell.roundedCorner = []

            if indexPath.row == dataSource.sectionModels[indexPath.section].items.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            return cell
        }
        
        if let user = item.profileValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "\(SubscribersCell.self)") as! SubscribersCell
            cell.setUp(with: user)
            cell.delegate = self
            
            cell.roundedCorner = []

            if indexPath.row == dataSource.sectionModels[indexPath.section].items.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            return cell
        }
        
        if let post = item.postValue {
            let cell: PostCell
            switch post.document?.attributes?.type {
            case "article":
                cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                cell.setUp(with: post)
            case "basic":
                cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                cell.setUp(with: post)
            default:
                return UITableViewCell()
            }

            return cell
        }

        return UITableViewCell()
    }
    
    override func bindItems() {
        let viewModel = self.viewModel as! DiscoveryAllViewModel
        
        Observable.merge(
            viewModel.subscriptions.filter {_ in viewModel.isQueryEmpty},
            viewModel.items.filter {_ in !viewModel.isQueryEmpty}.asObservable()
        )
            .map {items -> [ListSection] in
                let communities = items.filter {$0.communityValue != nil && $0.communityValue?.isSubscribed == true}
                let followers = items.filter {$0.profileValue != nil && $0.profileValue?.isSubscribed == true}
                let posts = items.filter {$0.postValue != nil}
                var sections = [ListSection]()
                if !communities.isEmpty {
                    sections.append(ListSection(model: "communities", items: communities))
                }
                if !followers.isEmpty {
                    sections.append(ListSection(model: (self.viewModel as! SearchViewModel).isQueryEmpty ? "following" : "users", items: followers))
                }
                if !posts.isEmpty {
                    sections.append(ListSection(model: "posts", items: posts))
                }
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func modelSelected(_ item: ResponseAPIContentSearchItem) {
        if let community = item.communityValue {
            showCommunityWithCommunityId(community.communityId)
            return
        }
        
        if let user = item.profileValue {
            showProfileWithUserId(user.userId)
            return
        }
    }
    
    override func handleListEmpty() {
        let title = "no result".localized().uppercaseFirst
        let description = "try to look for something else".localized().uppercaseFirst
        tableView.addEmptyPlaceholderFooterView(emoji: "😿", title: title, description: description)
    }
    
    // MARK: - Search
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SearchViewModel).query = query
        viewModel.reload(clearResult: false)
    }
    func searchBarDidCancelSearching() {
        (viewModel as! SearchViewModel).query = nil
        viewModel.reload(clearResult: false)
    }
    
    // MARK: - Actions
    @objc func seeAllButtonDidTouch(gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else {return}
        seeAllHandler?(index)
    }
}

extension DiscoveryAllVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let headerView = UIView(backgroundColor: .white)
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model.localized().uppercaseFirst, textSize: 15, weight: .semibold)
        headerView.addSubview(label)
        label.autoPinBottomAndLeadingToSuperView(inset: 5, xInset: 16)
        
        if dataSource.sectionModels[section].items.count == 5 {
            let seeAllLabel = UILabel.with(text: "see all".localized(), textSize: 15, weight: .semibold, textColor: .appMainColor)
            headerView.addSubview(seeAllLabel)
            seeAllLabel.autoPinBottomAndTrailingToSuperView(inset: 5, xInset: 16)
            
            switch dataSource.sectionModels[section].model {
            case "communities":
                seeAllLabel.tag = 1
            case "users", "following":
                seeAllLabel.tag = 2
            case "posts":
                seeAllLabel.tag = 3
            default:
                break
            }
            
            seeAllLabel.isUserInteractionEnabled = true
            seeAllLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(seeAllButtonDidTouch(gesture:))))
        }
        
        DispatchQueue.main.async {
            headerView.roundCorners([.topLeft, .topRight], radius: 10)
        }
        return view
    }
}
