//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation
import RxSwift
import ESPullToRefresh

class ProfileVC<ProfileType: Decodable>: BaseViewController {
    // MARK: - Constants
    let coverHeight: CGFloat = 200
    let coverVisibleHeight: CGFloat = 150
    var coverImageHeightConstraint: NSLayoutConstraint!
    var coverImageWidthConstraint: NSLayoutConstraint!

    let disposeBag = DisposeBag()
    
    // MARK: - Properties
    var _viewModel: ProfileViewModel<ProfileType> {
        fatalError("Must override")
    }
    
    // MARK: - Subviews
    
    lazy var shadowView: UIView = {
        let view = UIView(forAutoLayout: ())
        view.backgroundColor = .clear
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: coverHeight)
        gradient.colors = [UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.clear.cgColor]
        gradient.locations = [0.0, 0.5]
        view.layer.insertSublayer(gradient, at: 0)
        return view
    }()
    
    lazy var backButton = UIButton.back(tintColor: .white, contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 24))
    
    lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .placeholder
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
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
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = #colorLiteral(red: 0.9605136514, green: 0.9644123912, blue: 0.9850376248, alpha: 1)
        setLeftNavBarButton(with: backButton)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)

        let screenWidth = UIScreen.main.bounds.size.width
        view.addSubview(coverImageView)
        coverImageView.autoPinEdge(toSuperviewEdge: .top)
        coverImageView.autoAlignAxis(.vertical, toSameAxisOf: view)
        
        coverImageWidthConstraint = coverImageView.widthAnchor.constraint(equalToConstant: screenWidth)
        coverImageWidthConstraint.isActive = true
        coverImageHeightConstraint = coverImageView.heightAnchor.constraint(equalToConstant: coverHeight)
        coverImageHeightConstraint.isActive = true

        view.addSubview(shadowView)
        shadowView.autoPinEdgesToSuperviewEdges()

        view.addSubview(tableView)
        tableView.autoPinEdgesToSuperviewEdges()
        tableView.contentInset.top = coverVisibleHeight

        // setup datasource
        tableView.register(BasicPostCell.self, forCellReuseIdentifier: "BasicPostCell")
        tableView.register(ArticlePostCell.self, forCellReuseIdentifier: "ArticlePostCell")
        
        tableView.separatorStyle = .none
        tableView.setContentOffset(CGPoint(x: 0, y: -coverHeight), animated: true)
        
        // pull to refresh
        tableView.es.addPullToRefresh { [unowned self] in
            self.tableView.es.stopPullToRefresh()
            self.reload()
        }
        tableView.subviews.first(where: {$0 is ESRefreshHeaderView})?.alpha = 0
    }
    
    override func bind() {
        super.bind()
        bindControls()
        
        bindProfile()
        
        bindList()
    }
    
    func setUp(profile: ProfileType) {
    }
    
    func handleListLoading(isLoading: Bool) {
        
    }
    
    func handleListEnded() {
        
    }
    
    func handleListEmpty() {
        
    }
    
    func bindItems() {
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isTranslucent = true

        if tableView.contentOffset.y >= -43 {
            showTitle(true)
        } else {
            showTitle(false)
        }
    }
    
    func showTitle(_ show: Bool, animated: Bool = false) {
        coverImageView.isHidden = show
        UIView.animate(withDuration: animated ? 0.3: 0) {
            self.setStatusBarStyle(show ? .default : .lightContent)
            self.navigationController?.navigationBar.subviews.first?.backgroundColor = show ? .white: .clear
            self.navigationController?.navigationBar.setTitleFont(.boldSystemFont(ofSize: 17), color:
                show ? .black: .clear)
            self.backButton.tintColor = show ? .black: .white
        }
    }
    
    @objc func reload() {
        _viewModel.reload()
        _viewModel.fetchNext(forceRetry: true)
    }
}
