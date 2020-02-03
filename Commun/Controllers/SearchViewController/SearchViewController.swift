//
//  SearchViewController.swift
//  Commun
//
//  Created by Chung Tran on 2/1/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class SearchViewController: ListViewController<ResponseAPIContentSearchItem, PostCell>, CommunityCellDelegate, PostCellDelegate {
    // MARK: - Properties
    override var isSearchEnabled: Bool {true}
    
    // MARK: - Subviews
    lazy var topTabBar = CMTopTabBar(
        height: 35,
        labels: [
            "all".localized().uppercaseFirst,
            "communities".localized().uppercaseFirst,
            "users".localized().uppercaseFirst,
            "posts".localized().uppercaseFirst
        ],
        selectedIndex: 0,
        contentInset: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    )
    
    // MARK: - Initializers
    init() {
        let vm = SearchViewModel()
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewWillSetUpTableView() {
        super.viewWillSetUpTableView()
        // topTabBar
        view.addSubview(topTabBar)
        topTabBar.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .bottom)
        topTabBar.scrollView.contentOffset.x = -16
    }
    
    override func setUpTableView() {
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        tableView.autoPinEdge(.top, to: .bottom, of: topTabBar, withOffset: 10)
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
    }
    
    override func registerCell() {
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        tableView.register(CommunityCell.self, forCellReuseIdentifier: "CommunityCell")
//        tableView.register(SubscriptionsUserCell.self, forCellReuseIdentifier: "SubscriptionsUserCell")
    }
    
    override func configureCell(with item: ResponseAPIContentSearchItem, indexPath: IndexPath) -> UITableViewCell {
        if let community = item.communityValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommunityCell") as! CommunityCell
            cell.setUp(with: community)
            cell.delegate = self
            
            cell.roundedCorner = []
            
            if indexPath.row == 0 {
                cell.roundedCorner.insert([.topLeft, .topRight])
            }
            
            if indexPath.row == self.viewModel.items.value.count - 1 {
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
            
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func bind() {
        super.bind()
        // forward delegate
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    override func handleListEmpty() {
        let title = "no post"
        let description = "posts not found"
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst, buttonLabel: "reload".localized().uppercaseFirst + "?") {
            self.viewModel.reload()
        }
    }
    
    override func search(_ keyword: String?) {
        guard let keyword = keyword, !keyword.isEmpty else {
            return
        }
        
        if self.viewModel.fetcher.search != keyword {
            self.viewModel.fetcher.search = keyword
            self.viewModel.reload(clearResult: false)
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let post = viewModel.items.value[safe: indexPath.row],
            let height = viewModel.rowHeights[post.identity]
        else {return UITableView.automaticDimension}
        return height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let post = viewModel.items.value[safe: indexPath.row]
        else {return 200}
        return viewModel.rowHeights[post.identity] ?? 200
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let post = viewModel.items.value[safe: indexPath.row]
        else {return}
        viewModel.rowHeights[post.identity] = cell.bounds.height
    }
}
