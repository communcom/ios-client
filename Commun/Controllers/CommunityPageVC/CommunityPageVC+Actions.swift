//
//  CommunityPageVC+Actions.swift
//  Commun
//
//  Created by Chung Tran on 11/21/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension CommunityPageVC {
    func hideCommunity() {
        guard let id = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("hiding".localized().uppercaseFirst + "...")
        
        BlockchainManager.instance.hideCommunity(id)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "community hidden".localized().uppercaseFirst,
                    message: "you've hidden".localized().uppercaseFirst + " \(self.viewModel.profile.value?.name ?? self.viewModel.profile.value?.communityId ?? "this community".localized())" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
                        var profile = self.viewModel.profile.value
                        profile?.isInBlacklist = true
                        profile?.notifyChanged()
                        
                        profile?.notifyDeleted()
                        profile?.notifyEvent(eventName: ResponseAPIContentGetCommunity.blockedEventName)
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func unhideCommunity() {
        guard let id = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("unhiding".localized().uppercaseFirst + "...")
        
        BlockchainManager.instance.unhideCommunity(id)
            .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
            .subscribe(onCompleted: {
                self.hideHud()
                self.showAlert(
                    title: "community unhidden".localized().uppercaseFirst,
                    message: "you've unhidden".localized().uppercaseFirst + " \(self.viewModel.profile.value?.name ?? self.viewModel.profile.value?.communityId ?? "this community")" + ".") { _ in
                        var profile = self.viewModel.profile.value
                        profile?.isInBlacklist = false
                        profile?.notifyChanged()
                    }
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    @objc func getPointsButtonTapped(_ sender: UIButton) {
        guard let viewModel = viewModel as? CommunityPageViewModel,
            let communityCode = viewModel.community.value?.code ?? viewModel.community.value?.communityId,
            let price = self.price
        else { return }
        
        let vm = BalancesViewModel.ofCurrentUser
        
        let showGetPointsVC: (() -> Void) =
            { [weak self] in
                let vc = GetPointsVC(balances: vm.items.value, symbol: communityCode)
                vc.backButtonHandler = {
                    self?.navigationController?.popToVC(type: Self.self)
                }
                self?.show(vc, sender: nil)
            }
        
        if !vm.items.value.contains(where: {$0.symbol == communityCode}) {
            showAlert(title: "open balance".localized().uppercaseFirst, message: "you do not have balance for this community.\nWould you like to open one?".localized().uppercaseFirst, buttonTitles: ["open".localized().uppercaseFirst, "cancel".localized().uppercaseFirst], highlightedButtonIndex: 0) { (index) in
                if index == 0 {
                    self.showIndetermineHudWithMessage("open balance".localized().uppercaseFirst)
                    BlockchainManager.instance.openCommunityBalance(communityCode: communityCode)
                        .flatMapCompletable {RestAPIManager.instance.waitForTransactionWith(id: $0)}
                        .subscribe(onCompleted: {
                            self.hideHud()
                            let balance = ResponseAPIWalletGetBalance(symbol: communityCode, balance: "0", logo: viewModel.profile.value?.avatarUrl, name: viewModel.profile.value?.name, frozen: "0", price: Conflicted(string: price.string))
                            var items = vm.items.value
                            items.append(balance)
                            vm.items.accept(items)
                            showGetPointsVC()
                        }) { (error) in
                            self.hideHud()
                            self.showError(error)
                        }
                        .disposed(by: self.disposeBag)
                }
            }
        } else {
            showGetPointsVC()
        }
    }
    
    @objc func showCommunityControlPanel() {
        guard let profile = viewModel.profile.value else {return}
        
        let headerView = CMMetaView(forAutoLayout: ())
        headerView.avatarImageView.setAvatar(urlString: profile.avatarUrl)
        headerView.titleLabel.text = profile.name
        headerView.subtitleLabel.text = profile.communityId
        
        // report action
        let reportAction: CMActionSheet.Action = {
            let action = CMActionSheet.Action.iconFirst(
                title: "reports".localized().uppercaseFirst,
                iconName: "manage-community-reports",
                handle: {
                    self.openReportsVC()
                },
                showNextButton: true
            )
            let stackView = action.view.subviews.first as! UIStackView
            let countLabel = UILabel.with(text: "+\((viewModel as! CommunityPageViewModel).reportsVM.reportsCount)", textSize: 15, weight: .semibold, textColor: .appMainColor)
            
            stackView.insertArrangedSubview(countLabel, at: stackView.arrangedSubviews.count - 1)
            return action
        }()
        
        // proposal action
        let proposalAction: CMActionSheet.Action = {
            let action = CMActionSheet.Action.iconFirst(
                title: "proposals".localized().uppercaseFirst,
                iconName: "manage-community-proposals",
                handle: {
                    self.openProposalsVC()
                },
                bottomMargin: 16,
                showNextButton: true
            )
            let stackView = action.view.subviews.first as! UIStackView
            let countLabel = UILabel.with(text: "+\((viewModel as! CommunityPageViewModel).proposalsVM.proposalsCount)", textSize: 15, weight: .semibold, textColor: .appMainColor)
            stackView.insertArrangedSubview(countLabel, at: stackView.arrangedSubviews.count - 1)
            return action
        }()
        
        let settingAction = CMActionSheet.Action.iconFirst(
            title: "settings".localized().uppercaseFirst,
            iconName: "profile_options_settings",
            handle: {
                self.manageCommunityDidTouch()
            },
            showNextButton: true
        )
        
        showCMActionSheet(headerView: headerView, actions: [reportAction, proposalAction, settingAction])
    }
    
    @objc func manageCommunityDidTouch() {
        guard let community = self.viewModel.profile.value else {return}
        let vc = EditCommunityVC(community: community)
        self.show(vc, sender: nil)
    }
    
    @objc func proposalsButtonDidTouch() {
        switch (viewModel as! CommunityPageViewModel).proposalsVM.state.value {
        case .loading(true):
            return
        case .loading(false), .listEnded, .listEmpty:
            openProposalsVC()
        case .error:
            (viewModel as! CommunityPageViewModel).proposalsVM.reload(clearResult: true)
        }
    }
    
    @objc func reportsButtonDidTouch() {
        switch (viewModel as! CommunityPageViewModel).reportsVM.state.value {
        case .loading(true):
            return
        case .loading(false), .listEnded, .listEmpty:
            openReportsVC()
        case .error:
            (viewModel as! CommunityPageViewModel).reportsVM.reload(clearResult: true)
        }
    }
    
    @objc func becomeALeaderButtonDidTouch() {
        guard let communityId = viewModel.profile.value?.communityId else {return}
        showIndetermineHudWithMessage("vote yourself as a leader".localized().uppercaseFirst)
        (viewModel as! CommunityPageViewModel).regLeader(communityId: communityId)
            .subscribe(onCompleted: {
                self.hideHud()
                self.showDone("you voted yourself as a leader".localized().uppercaseFirst)
            }) { (error) in
                self.hideHud()
                self.showError(error)
            }
            .disposed(by: disposeBag)
    }
    
    func openReportsVC() {
        let vc = ReportsListVC(viewModel: (viewModel as! CommunityPageViewModel).reportsVM)
        show(vc, sender: nil)
    }
    
    func openProposalsVC() {
        let vc = ProposalsVC(viewModel: (viewModel as! CommunityPageViewModel).proposalsVM)
        show(vc, sender: nil)
    }
}
