//
//  FeedPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import CyberSwift
import RxSwift
import RxDataSources
import ESPullToRefresh

class FeedPageVC: UIViewController, VCWithParallax {
    // MARK: - Properties
    var viewModel: FeedPageViewModel!
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<PostSection>!
    let disposeBag = DisposeBag()
    var headerView: UIView! // for parallax
    var headerHeight: CGFloat = 151 // for parallax

    // MARK: - Outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var changeFeedTypeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userAvatarImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Config viewModel
        setUpViewModel()
        
        // setup views
        setUpViews()
        
        // bind ui
        bindUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    func setUpViewModel() {
        viewModel = FeedPageViewModel()
        
        // handlers
        viewModel.loadingHandler = { [weak self] in
            if self?.viewModel.fetcher.reachedTheEnd == true {return}
            self?.tableView.addPostLoadingFooterView()
        }
        
        viewModel.listEndedHandler = { [weak self] in
            self?.tableView.tableFooterView = UIView()
        }
        
        viewModel.fetchNextErrorHandler = {[weak self] error in
            guard let strongSelf = self else {return}
            strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
            strongSelf.tableView.reloadData()
        }
    }
    
    func setUpViews() {
        // RefreshControl
        tableView.es.addPullToRefresh { [unowned self] in
            self.tableView.es.stopPullToRefresh()
            self.refresh()
        }
        
        // parallax
        constructParallax()
        
        // avatarImage
        userAvatarImage
            .observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        userAvatarImage.addTapToViewer()
        
        // tableView
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        
        dataSource = MyRxTableViewSectionedAnimatedDataSource<PostSection>(
            configureCell: { dataSource, tableView, indexPath, post in
                let cell: PostCell
                switch post.content.attributes?.type {
                case "article":
                    cell = self.tableView.dequeueReusableCell(withIdentifier: "ArticlePostCell") as! ArticlePostCell
                    cell.setUp(with: post)
                case "basic":
                    cell = self.tableView.dequeueReusableCell(withIdentifier: "BasicPostCell") as! BasicPostCell
                    cell.setUp(with: post)
                default:
                    return UITableViewCell()
                }
                
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
        
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.addPostLoadingFooterView()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
        
        var contentInsets = tableView.contentInset
        contentInsets.bottom = tabBarController!.tabBar.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        
        tableView.contentInset = contentInsets
    }
}
