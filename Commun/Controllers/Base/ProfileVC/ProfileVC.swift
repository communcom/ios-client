//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift

class ProfileVC<ProfileType: Decodable>: BaseViewController {
    override var contentScrollView: UIScrollView? {tableView}
    override var title: String? {
        get {
            return navigationBar.title
        }
        set {
            navigationBar.title = newValue
        }
    }
    
    // MARK: - Constants
    let coverHeight: CGFloat = 180
    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    var _viewModel: ProfileViewModel<ProfileType> {
        fatalError("Must override")
    }
    
    // MARK: - Subviews
    lazy var navigationBar = MyNavigationBar(height: 60)
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView(height: coverHeight)
        imageView.image = UIImage(named: "ProfilePageCover")
        return imageView
    }()
    
    var _headerView: ProfileHeaderView! {
        fatalError("Must override")
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        return tableView
    }()
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9605136514, green: 0.9644123912, blue: 0.9850376248, alpha: 1)
        navigationItem.backBarButtonItem?.title = " "
        
        view.addSubview(navigationBar)
        navigationBar.autoPinEdge(toSuperviewEdge: .leading)
        navigationBar.autoPinEdge(toSuperviewEdge: .trailing)
        navigationBar.autoPinEdge(toSuperviewSafeArea: .top)
        navigationBar.backButton.tintColor = .white
        navigationBar.titleLabel.textColor = .clear
        navigationBar.backgroundColor = .clear
        
        view.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset = UIEdgeInsets(top: coverHeight - 24, left: 0, bottom: 0, right: 0)
        
        view.bringSubviewToFront(navigationBar)
        
        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        
        tableView.separatorStyle = .none
    }
    
    override func bind() {
        super.bind()
        bindControls()
        
        bindProfile()
        
        bindList()
    }
    
    func setUp(profile: ProfileType) {
    }
    
    func handleListLoading() {
        
    }
    
    func handleListEmpty() {
        
    }
    
    func createCell(for table: UITableView, index: Int, element: Any) -> UITableViewCell? {
        if let post = element as? ResponseAPIContentGetPost {
            switch post.document.attributes?.type {
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
        }
        return nil
    }
    
    func cellSelected(_ indexPath: IndexPath) {
        
    }
    
    @objc func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            _viewModel.fetchNext(forceRetry: true)
        }
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
}
