//
//  PhotoLibraryAccessDeniedView.swift
//  Commun
//
//  Created by Artem Shilin on 24.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PhotoLibraryAccessDeniedView: MyView {
    private let bag = DisposeBag()

    override func commonInit() {
        super.commonInit()

        let titleLabel = UILabel(text: "allow access to your photos".localized().uppercaseFirst, font: .systemFont(ofSize: 24, weight: .bold), numberOfLines: 2, color: .black)
        titleLabel.textAlignment = .center
        addSubview(titleLabel)
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 50, left: 15, bottom: 15, right: 15), excludingEdge: .bottom)

        let subtitleLabel = UILabel(text: "access was previously denied, please grant".localized().uppercaseFirst, font: .systemFont(ofSize: 17, weight: .semibold), numberOfLines: 2, color: .appGrayColor)
        subtitleLabel.textAlignment = .center
        addSubview(subtitleLabel)
        subtitleLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 10)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 20)
        subtitleLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 20)

        let button = CommunButton(width: 180, height: 50, backgroundColor: .appMainColor, cornerRadius: 25)
        addSubview(button)
        button.autoAlignAxis(toSuperviewAxis: .vertical)
        button.autoPinEdge(.top, to: .bottom, of: subtitleLabel, withOffset: 30)
        button.autoPinEdge(toSuperviewSafeArea: .bottom, withInset: 15)
        button.setTitle("Open Settings", for: .normal)

        button.rx.tap.subscribe { _ in
           print("123")
           UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }.disposed(by: bag)
    }
}
