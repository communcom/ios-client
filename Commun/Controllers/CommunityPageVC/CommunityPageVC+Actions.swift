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
                    message: "you've hidden".localized().uppercaseFirst + " \(self.viewModel.profile.value?.communityId ?? "this community".localized())" + ".\n" + "we're sorry that you've had this experience".localized().uppercaseFirst + ".") { _ in
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
                    message: "You've unhidden" + " \(self.viewModel.profile.value?.communityId ?? "this community")" + ".") { _ in
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
}
