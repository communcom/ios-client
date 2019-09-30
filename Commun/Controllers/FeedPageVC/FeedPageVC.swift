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

class FeedPageVC: UIViewController {
    // MARK: - Properties
    var viewModel: FeedPageViewModel!
    var dataSource: MyRxTableViewSectionedAnimatedDataSource<PostSection>!
    let disposeBag = DisposeBag()

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
        // avatarImage
        userAvatarImage
            .observeCurrentUserAvatar()
            .disposed(by: disposeBag)
        
        userAvatarImage.addTapToViewer()
        
        // tableView
        dataSource = MyRxTableViewSectionedAnimatedDataSource<PostSection>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCardCell", for: indexPath) as! PostCardCell
                cell.setUp(with: item)
                
                if indexPath.row >= self.viewModel.items.value.count - 5 {
                    self.viewModel.fetchNext()
                }
                
                return cell
            }
        )
        
        tableView.contentInset = UIEdgeInsets(
            top: -UIApplication.shared.statusBarFrame.height,
            left: 0,
            bottom: 0,
            right: 0)
        
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.addPostLoadingFooterView()
        
        // RefreshControl
        tableView.es.addPullToRefresh { [unowned self] in
            self.refresh()
            self.tableView.es.stopPullToRefresh()
        }
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        // dismiss keyboard when dragging
        tableView.keyboardDismissMode = .onDrag
    }
}
