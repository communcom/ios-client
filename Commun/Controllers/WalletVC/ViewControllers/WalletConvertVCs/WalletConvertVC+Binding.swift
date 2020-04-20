//
//  WalletConvertVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 3/13/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

extension WalletConvertVC {
    func bindState() {
        viewModel.state
            .subscribe(onNext: { (state) in
                switch state {
                case .error(error: let error):
                    #if !APPSTORE
                        self.showError(error)
                    #endif
                    self.view.showErrorView {
                        self.view.hideErrorView()
                        self.viewModel.reload()
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        // price loading state
        viewModel.priceLoadingState
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (state) in
                switch state {
                case .loading:
                    if !(self?.rightTextField.isFirstResponder ?? false) {
                        self?.rightTextField.hideLoader()
                        self?.rightTextField.showLoader()
                    }
                    
                    if !(self?.leftTextField.isFirstResponder ?? false) {
                        self?.leftTextField.hideLoader()
                        self?.leftTextField.showLoader()
                    }
                    
                    self?.convertButton.isDisabled = true
//                    self?.convertButton.isEnabled = false
                
                case .finished:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.convertButton.isDisabled = !(self?.shouldEnableConvertButton() ?? false)
//                    self?.convertButton.isEnabled = self?.shouldEnableConvertButton() ?? false
                
                case .error:
                    self?.rightTextField.hideLoader()
                    self?.leftTextField.hideLoader()
                    
                    self?.convertButton.isDisabled = true
//                    self?.convertButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    func bindScrollView() {
        let keyboardOnOffset: CGFloat = 161.5
        var additionalBottomInset: CGFloat?
        switch UIDevice.current.screenType {
        case .iPhones_6_6s_7_8:
            additionalBottomInset = 51
        case .iPhones_6Plus_6sPlus_7Plus_8Plus:
            additionalBottomInset = 110.5
        case .iPhones_X_XS, .iPhone_11Pro:
            additionalBottomInset = 97.5
        case .iPhone_XR_11:
            additionalBottomInset = 171
        case .iPhone_XSMax_ProMax:
            additionalBottomInset = 171.5
        case .unknown:
            break
        default:
            break
        }
        
        // handle keyboard
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    if let additionalBottomInset = additionalBottomInset {
                        self.scrollView.contentInset.bottom = additionalBottomInset
                    }
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidShowNotification)
            .subscribe { _ in
                DispatchQueue.main.async {
                    let bottomOffset = CGPoint(x: 0, y: keyboardOnOffset)
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardDidHideNotification)
            .subscribe { _ in
                if additionalBottomInset != nil {
                    self.scrollView.contentInset.bottom = 0
                }
            }
            .disposed(by: disposeBag)
        
        let convertLogoContainerViewBottomConstraint = convertLogoTopView.autoPinEdge(.bottom, to: .top, of: whiteView)
        scrollView.rx.contentOffset
            .map {$0.y}
            .subscribe(onNext: { (offsetY) in
                print(offsetY)
                print("\(self.scrollView.contentSize.height)")
                print("\(self.view.safeAreaInsets.top)")
                
                if offsetY >= keyboardOnOffset {
                    convertLogoContainerViewBottomConstraint.isActive = false
                    self.navigationController?.navigationBar.subviews.first?.backgroundColor = self.topColor
                    self.convertLogoTopView.heightConstraint?.constant = 30
                } else {
                    convertLogoContainerViewBottomConstraint.isActive = true
                    self.navigationController?.navigationBar.subviews.first?.backgroundColor = .clear
                    self.convertLogoTopView.heightConstraint?.constant = 0
                }
                    
                let titleLabel = UILabel.with(text: "convert".localized().uppercaseFirst, textSize: 15, weight: .semibold, textColor: .white, numberOfLines: 2, textAlignment: .center)
                
                if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 6) {
                    if offsetY >= self.view.safeAreaInsets.top + CGFloat.adaptive(height: 33) {
                        titleLabel.attributedText = NSMutableAttributedString()
                            .text(self.balanceNameLabel.text ?? "", size: 14, weight: .semibold, color: .white)
                            .text("\n")
                            .text(self.valueLabel.text ?? "", size: 16, weight: .semibold, color: .white)
                        self.balanceNameLabel.isHidden = true
                        self.valueLabel.isHidden = true
                    } else {
                        titleLabel.text = self.balanceNameLabel.text
                        self.balanceNameLabel.isHidden = true
                        self.valueLabel.isHidden = false
                    }
                } else {
                    self.balanceNameLabel.isHidden = false
                    self.valueLabel.isHidden = false
                }
                self.navigationItem.titleView = titleLabel
                self.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
    }
}
