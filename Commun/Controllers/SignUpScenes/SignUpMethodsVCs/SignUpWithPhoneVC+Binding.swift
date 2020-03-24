//
//  SignUpWithPhoneVC+Binding.swift
//  Commun
//
//  Created by Chung Tran on 3/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

extension SignUpWithPhoneVC {
    func bindCountry() {
        let country = viewModel.selectedCountry

        country
            .filter {$0 != nil}
            .subscribe(onNext: { (_) in
                self.shouldDefineLocation = false
            })
            .disposed(by: disposeBag)
        
        // Bind country name
        country.map {$0?.name ?? ""}
            .subscribe(onNext: { (name) in
                self.selectCountryView.removeSubviews()
                
                if name.isEmpty {
                    self.selectCountryView.addSubview(self.selectCountryPlaceholderLabel)
                    self.selectCountryPlaceholderLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
                    self.selectCountryPlaceholderLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
                } else {
                    self.selectCountryView.addSubview(self.flagView)
                    self.flagView.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
                    self.flagView.autoAlignAxis(toSuperviewAxis: .horizontal)
                    
                    self.selectCountryView.addSubview(self.countryNameLabel)
                    self.countryNameLabel.autoPinEdge(.leading, to: .trailing, of: self.flagView, withOffset: 16)
                    self.countryNameLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
                    self.countryNameLabel.text = name
                }
            })
            .disposed(by: disposeBag)
        
        // Bind flag
        country.map {$0?.emoji}
            .bind(to: flagView.rx.text)
            .disposed(by: disposeBag)

        // Bind textField
        country
            .filter {$0 != nil}
            .map {$0!}
            .distinctUntilChanged {$0.code == $1.code}
            .map {"+\($0.code)"}
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindPhoneNumber() {
        let country = viewModel.selectedCountry
        
        // Bind phone
        phoneTextField.rx.text.orEmpty
            .map {text -> String in
                if let code = country.value?.code {
                    var newText = text
                    let cleanPhone = newText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    if !("+\(cleanPhone)").contains("+\(code)") {

                        if "+\(country.value!.code)".contains(text) {
                            return "+\(code)"
                        }

                        newText = "+\(code)\(newText)"
                    }
                    return newText
                }
                return text
            }
            .subscribe(onNext: { (text) in
                if self.phoneTextField.isFirstResponder && text.isEmpty {
                    self.chooseCountry()
                } else {
                    self.phoneTextField.text = text
                    self.viewModel.phone.accept(text)
                }
            })
            .disposed(by: disposeBag)

        // Bind button
        viewModel.phone
            .map {_ in self.viewModel.validatePhoneNumber()}
            .bind(to: self.nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
