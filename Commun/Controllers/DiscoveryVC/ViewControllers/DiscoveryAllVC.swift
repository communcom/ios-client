//
//  DiscoveryAllVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class DiscoveryAllVC: SubsViewController<ResponseAPIContentSearchItem, SubscribersCell>, CommunityCellDelegate, ProfileCellDelegate {
    // MARK: - Properties
    var seeAllHandler: ((Int) -> Void)?
    
    // MARK: - Initializers
    init(seeAllHandler: ((Int) -> Void)? = nil) {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).searchType = .extendedSearch
        (vm.fetcher as! SearchListFetcher).extendedSearchEntity = [
            .profiles: ["limit": 5, "offset": 0],
            .communities: ["limit": 5, "offset": 0],
//            .posts: ["limit": 5, "offset": 0]
        ]
        self.seeAllHandler = seeAllHandler
        
        // prefetch
        vm.fetchNext()
        
        super.init(viewModel: vm)
        
        defer {
            showShadowWhenScrollUp = false
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
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
    
    override func bindItems() {
        viewModel.items
            .map {items -> [ListSection] in
                let communities = items.filter {$0.communityValue != nil}
                let followers = items.filter {$0.profileValue != nil}
//                let posts = items.filter {$0.postValue != nil}
                var sections = [ListSection]()
                if !communities.isEmpty {
                    sections.append(ListSection(model: "communities", items: communities))
                }
                if !followers.isEmpty {
                    sections.append(ListSection(model: "users", items: followers))
                }
//                if !posts.isEmpty {
//                    sections.append(ListSection(model: "posts", items: posts))
//                }
                return sections
            }
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func registerCell() {
        super.registerCell()
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
//        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
//        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
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
        
//        if let post = item.postValue {
//            let cell: PostCell
//            switch post.document?.attributes?.type {
//            case "article":
//                cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
//                cell.setUp(with: post)
//            case "basic":
//                cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
//                cell.setUp(with: post)
//            default:
//                return UITableViewCell()
//            }
//
//            return cell
//        }

        return UITableViewCell()
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
    
    override func handleEmptyKeyword() {
        viewModel.reload()
    }
    
    // MARK: - Actions
    @objc func seeAllButtonDidTouch(gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else {return}
        seeAllHandler?(index)
    }
}

extension DiscoveryAllVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        
        let headerView = UIView(backgroundColor: .white)
        view.addSubview(headerView)
        headerView.autoPinEdgesToSuperviewEdges()
        
        let label = UILabel.with(text: dataSource.sectionModels[section].model.localized().uppercaseFirst, textSize: 15, weight: .semibold)
        headerView.addSubview(label)
        label.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label.autoAlignAxis(toSuperviewAxis: .horizontal)
        
        if dataSource.sectionModels[section].items.count == 5 {
            let seeAllLabel = UILabel.with(text: "see all".localized(), textSize: 15, weight: .semibold, textColor: .appMainColor)
            headerView.addSubview(seeAllLabel)
            seeAllLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
            seeAllLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            
            switch dataSource.sectionModels[section].model {
            case "communities":
                seeAllLabel.tag = 1
            case "users":
                seeAllLabel.tag = 2
//            case "posts":
//                seeAllLabel.tag = 3
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
