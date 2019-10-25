//
//  CommunityPageVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 10/25/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension CommunityPageVC {
    func bindCommunity() {
        #warning("retry button")
        //        let retryButton = UIButton(forAutoLayout: ())
        //        retryButton.setTitleColor(.gray, for: .normal)
        // bind community loading state
        viewModel.loadingState
            .subscribe(onNext: { [weak self] loadingState in
                switch loadingState {
                case .loading:
                    self?.view.showLoading()
                case .finished:
                    self?.view.hideLoading()
                case .error(let error):
                    self?.showError(error)
                    self?.back()
                }
            })
            .disposed(by: disposeBag)
        
        // bind content
        viewModel.community
            .filter {$0 != nil}
            .map {$0!}
            .do(onNext: { (_) in
                self.headerView.selectedIndex.accept(0)
            })
            .subscribe(onNext: { [weak self] (community) in
                self?.setUpWithCommunity(community)
            })
            .disposed(by: disposeBag)
    }
    
    func bindList() {
        // list loading state
        viewModel.listLoadingState
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading(let isLoading):
                    if (isLoading) {
                        switch self?.viewModel.segmentedItem.value {
                        case .posts:
                            self?.tableView.addPostLoadingFooterView()
                        case .leads:
                            self?.tableView.addNotificationsLoadingFooterView()
                        default:
                            break
                        }
                    }
                    else {
                        self?.tableView.tableFooterView = UIView()
                    }
                    break
                case .listEnded:
                    #warning("add empty state")
                    self?.tableView.tableFooterView = UIView()
                case .error(_):
                    guard let strongSelf = self else {return}
                    strongSelf.tableView.addListErrorFooterView(with: #selector(strongSelf.didTapTryAgain(gesture:)), on: strongSelf)
                    strongSelf.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        // bind items
        let items = viewModel.items
        
        items
            .bind(to: tableView.rx.items) {table, index, element in
                if index == self.tableView.numberOfRows(inSection: 0) - 2 {
                    self.viewModel.fetchNext()
                }
                
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
                        return UITableViewCell()
                    }
                }
                
                if let user = element as? ResponseAPIContentResolveProfile {
                    let cell = self.tableView.dequeueReusableCell(withIdentifier: "CommunityLeaderCell") as! CommunityLeaderCell
                    #warning("fix later")
//                    cell.textLabel?.text = user.username
//                    cell.imageView?.setAvatar(urlString: user.avatarUrl, namePlaceHolder: user.username)
                    return cell
                }
                
                if let string = element as? String {
                    let cell = UITableViewCell(style: .default, reuseIdentifier: "TestCell")
                    cell.textLabel?.text = string
                    return cell
                }
                
                return UITableViewCell()
            }
            .disposed(by: disposeBag)
    }
    
    func bindControls() {
        // Bind segmentedItem
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
        
        // headerView parallax
        tableView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: {offsetY in
                self.updateHeaderView()
            })
            .disposed(by: disposeBag)
    }
    
    private func updateHeaderView() {
        let offset = tableView.contentOffset.y
        if offset < -coverHeight {
            let originHeight = coverHeight
            
            let scale = -offset / (originHeight  - 24)
            coverImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            coverImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        coverImageView.layoutIfNeeded()
    }
    
    @objc private func didTapTryAgain(gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel,
            let text = label.text else {return}
        
        let tryAgainRange = (text as NSString).range(of: "try again".localized().uppercaseFirst)
        if gesture.didTapAttributedTextInLabel(label: label, inRange: tryAgainRange) {
            self.viewModel.fetchNext(forceRetry: true)
        }
    }
}
