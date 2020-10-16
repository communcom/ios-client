//
//  SearchUserVC.swift
//  Commun
//
//  Created by Chung Tran on 2/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

class SingleEntitySearchVC: ListViewController<ResponseAPIContentSearchItem, SubscribersCell>, SearchableViewControllerType, ProfileCellDelegate, CommunityCellDelegate, PostCellDelegate {
    // MARK: - Properties
    lazy var searchController = UISearchController.default()
    var searchBar: UISearchBar {
        get {searchController.searchBar}
        set {}
    }
    var posts: [ResponseAPIContentGetPost] {viewModel.items.value.compactMap {$0.postValue}}
    
    // MARK: - Initializers
    init(entityType: SearchEntityType) {
        let vm = SearchViewModel()
        (vm.fetcher as! SearchListFetcher).limit = 20
        (vm.fetcher as! SearchListFetcher).searchType = .entitySearch
        (vm.fetcher as! SearchListFetcher).entitySearchEntity = entityType
        super.init(viewModel: vm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchController.roundCorners()
    }
    
    override func setUp() {
        super.setUp()
        layoutSearchBar()
    }
    
    override func bind() {
        super.bind()
        bindSearchBar()
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
            
            if indexPath.row == 0 {
                cell.roundedCorner.insert([.topLeft, .topRight])
            }

            if indexPath.row == self.viewModel.items.value.count - 1 {
                cell.roundedCorner.insert([.bottomLeft, .bottomRight])
            }
            return cell
        }
        
        if let user = item.profileValue {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "\(SubscribersCell.self)") as! SubscribersCell
            cell.setUp(with: user)
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
            
            return cell
        }

        return UITableViewCell()
    }
    
    override func handleListEmpty() {
        let title = "no result".localized().uppercaseFirst
        let description = "try to look for something else".localized().uppercaseFirst
        tableView.addEmptyPlaceholderFooterView(emoji: "😿", title: title, description: description)
    }
    
    // MARK: - Search manager
    func layoutSearchBar() {
        // Place the search bar in the navigation item's title view.
        self.navigationItem.titleView = searchController.searchBar
    }
    
    func searchBarIsSearchingWithQuery(_ query: String) {
        (viewModel as! SearchViewModel).query = query
        viewModel.reload(clearResult: false)
    }
    
    func searchBarDidCancelSearching() {
        viewModel.state.accept(.loading(false))
        viewModel.items.accept([])
    }
}
