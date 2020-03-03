//
//  ProfileVC.swift
//  Commun
//
//  Created by Chung Tran on 10/22/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

class ProfileVC<ProfileType: Decodable>: BaseViewController {
    // MARK: - Constants
    let coverHeight: CGFloat = 200
    let coverVisibleHeight: CGFloat = 150
    var coverImageHeightConstraint: NSLayoutConstraint!
    var coverImageWidthConstraint: NSLayoutConstraint!
    let refreshControl = UIRefreshControl(forAutoLayout: ())
    
    // MARK: - Properties
    lazy var viewModel: ProfileViewModel<ProfileType> = self.createViewModel()
    var originInsetBottom: CGFloat?
    var frozenContentOffsetForRowAnimation: CGPoint?
    
    func createViewModel() -> ProfileViewModel<ProfileType> {
        fatalError("must override")
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
    
    lazy var optionsButton = UIButton.option(tintColor: .white)
    
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
    
    lazy var tableView: UITableView = setUpTableView()
    
    func setUpTableView() -> UITableView {
        let tableView = UITableView(forAutoLayout: ())
        tableView.backgroundColor = .clear
        tableView.insetsContentViewsToSafeArea = false
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }
    
    override func setUp() {
        super.setUp()

        view.backgroundColor = #colorLiteral(red: 0.9605136514, green: 0.9644123912, blue: 0.9850376248, alpha: 1)
        setLeftNavBarButtonForGoingBack(tintColor: .white)
        
        setRightNavBarButton(with: optionsButton)
        optionsButton.addTarget(self, action: #selector(moreActionsButtonDidTouch(_:)), for: .touchUpInside)

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

        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = .white
        refreshControl.subviews.first?.bounds.origin.y = 112
        
        _headerView.segmentedControl.delegate = self
    }

    @objc func refresh() {
        self.reload()
        refreshControl.endRefreshing()
    }

    override func bind() {
        super.bind()
        bindControls()
        
        bindProfile()
        
        bindList()
    }
    
    func bindProfile() {
        viewModel.profile
            .filter {$0 != nil}
            .map {$0!}
            .do(onNext: { (_) in
                self._headerView.selectedIndex.accept(0)
            })
            .subscribe(onNext: { [weak self] (item) in
                self?.setUp(profile: item)
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(profile: ProfileType) {
    }
    
    func handleListLoading() {
        
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
            viewModel.fetchNext(forceRetry: true)
        }
    }
    
    @objc func moreActionsButtonDidTouch(_ sender: CommunButton) {
        // for overriding
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.prefersLargeTitles = false

        showTitle(tableView.contentOffset.y >= -43)
    }

    func showTitle(_ show: Bool, animated: Bool = false) {
        navigationController?.navigationBar.addShadow(ofColor: .shadow, radius: CGFloat.adaptive(width: 16.0), offset: CGSize(width: 0.0, height: CGFloat.adaptive(height: 6.0)), opacity: 0.05)
        baseNavigationController?.changeStatusBarStyle(show ? .default : .lightContent)
        coverImageView.isHidden = show
        showNavigationBar(show, animated: animated) {
            self.optionsButton.tintColor = show ? .black: .white
            self.navigationItem.leftBarButtonItem?.tintColor = show ? .black: .white
            if !show {
                self.optionsButton.layer.shadowRadius = 2
                self.optionsButton.layer.shadowColor = UIColor.black.cgColor
                self.optionsButton.layer.shadowOffset = CGSize(width: 0, height: 1)
                self.optionsButton.layer.shadowOpacity = 0.25
                self.optionsButton.layer.masksToBounds = false
            } else {
                self.optionsButton.layer.shadowOpacity = 0
            }
        }
    }
    
    @objc func reload() {
        viewModel.reload()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if originInsetBottom == nil && tableView.contentInset.bottom > 0 {
            originInsetBottom = tableView.contentInset.bottom
        }
    }
}

extension ProfileVC: CMSegmentedControlDelegate {
    func segmentedControl(_ segmentedControl: CMSegmentedControl, didTapOptionAtIndex: Int) {
        // Add additional space to bottom of tableView to prevent jumping lag when swich tab
        let headerMaxY = _headerView.convert(_headerView.bounds, to: view).maxY
        
        let newInsetBottom: CGFloat = UIScreen.main.bounds.height - headerMaxY
        tableView.contentInset.bottom = newInsetBottom
        
        frozenContentOffsetForRowAnimation = tableView.contentOffset
        // Return contentInset to original value after updating
        tableView.rx.endUpdatesEvent
            .debounce(1, scheduler: MainScheduler.instance)
            .take(1)
            .asSingle()
            .subscribe(onSuccess: {[weak self] (_) in
                guard let strongSelf = self else {return}
                if let inset = strongSelf.originInsetBottom,
                    (UIScreen.main.bounds.height - strongSelf.tableView.contentSize.height + strongSelf.tableView.contentOffset.y < inset)
                {
                    strongSelf.tableView.contentInset.bottom = inset
                }
            })
            .disposed(by: disposeBag)
    }
}
