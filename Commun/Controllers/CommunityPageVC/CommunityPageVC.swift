//
//  CommunityVC.swift
//  Commun
//
//  Created by Chung Tran on 10/23/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class CommunityPageVC: ProfileVC<ResponseAPIContentGetCommunity>{
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
        headerView.roundCorners(UIRectCorner(arrayLiteral: .topLeft, .topRight), radius: 25)
    }
    
    override func bind() {
        super.bind()
        headerView.selectedIndex
            .map { index -> CommunityPageViewModel.SegmentioItem in
                switch index {
                case 0:
                    return .posts
                case 1:
                    return .leads
                case 2:
                    return .about
                case 3:
                    return .rules
                default:
                    fatalError("not found selected index")
                }
            }
            .bind(to: viewModel.segmentedItem)
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
        if let urlString = profile.coverUrl
        {
            coverImageView.setImageDetectGif(with: urlString)
        }
        
        // header
        headerView.setUp(with: profile)
    }
    
    override func handleListLoading() {
        switch viewModel.segmentedItem.value {
        case .posts:
            tableView.addPostLoadingFooterView()
        case .leads:
            tableView.addNotificationsLoadingFooterView()
        default:
            break
        }
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
        default:
            break
        }
        
        tableView.addEmptyPlaceholderFooterView(title: title.localized().uppercaseFirst, description: description.localized().uppercaseFirst)
    }
    
    override func createCell(for table: UITableView, index: Int, element: Any) -> UITableViewCell? {
        if let cell = super.createCell(for: table, index: index, element: element) {
            return cell
        }
        
        if let user = element as? ResponseAPIContentGetLeader {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
            #warning("fix later")
            cell.avatarImageView.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username ?? user.userId)
            cell.userNameLabel.text = user.username
//                    cell.textLabel?.text = user.username
//                    cell.imageView?.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username)
            return cell
        }
        
        if let string = element as? String {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityAboutCell") as! CommunityAboutCell
            cell.label.text = string
            return cell
        }
        
        if let rule = element as? ResponseAPIContentGetCommunityRule {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityRuleCell") as! CommunityRuleCell
            cell.rowIndex = index
            cell.setUp(with: rule)
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func cellSelected(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        switch cell {
        case is PostCell:
            if let postPageVC = controllerContainer.resolve(PostPageVC.self)
            {
                let post = self.viewModel.postsVM.items.value[indexPath.row]
                (postPageVC.viewModel as! PostPageViewModel).postForRequest = post
                self.show(postPageVC, sender: nil)
            } else {
                self.showAlert(title: "error".localized().uppercaseFirst, message: "something went wrong".localized().uppercaseFirst)
            }
            break
        case is CommunityLeaderCell:
            #warning("Tap a leaderCell")
            break
        default:
            break
        }
    }
}
