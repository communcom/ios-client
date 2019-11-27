//
//  AuthorizeOnWebVC.swift
//  Commun
//
//  Created by Chung Tran on 11/26/19.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

class AuthorizeOnWebVC: BaseViewController, BoardingRouter {
    // MARK: - Subviews
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "ftue-2")
        return imageView
    }()
    
    lazy var buttonDone = CommunButton.default(height: 50, label: "done".localized().uppercaseFirst)
    
    override func setUp() {
        super.setUp()
        view.backgroundColor = .white
        
        view.addSubview(imageView)
        imageView.autoPinEdge(toSuperviewEdge: .top, withInset: 10)
        imageView.autoAlignAxis(toSuperviewAxis: .vertical)
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/2 * Config.heightRatio)
            .isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            .isActive = true
        
        let label1 = UILabel.with(text: "authorize on web".localized().uppercaseFirst, textSize: 33, weight: .bold)
        view.addSubview(label1)
        label1.autoPinEdge(.top, to: .bottom, of: imageView, withOffset: 27)
        label1.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let label2 = UILabel.with(text: "triple your points".localized().uppercaseFirst, textSize: 33)
        view.addSubview(label2)
        label2.autoPinEdge(.top, to: .bottom, of: label1, withOffset: 4)
        label2.autoAlignAxis(toSuperviewAxis: .vertical)
        
        let label3 = UILabel.with(text: "right after you authorize on the Website\nWe triple your welcome points".localized().uppercaseFirst, textSize: 17, textColor: .a5a7bd, numberOfLines: 0, textAlignment: .center)
        view.addSubview(label3)
        label3.autoPinEdge(.top, to: .bottom, of: label2, withOffset: 20)
        label3.autoPinEdge(toSuperviewEdge: .leading, withInset: 16)
        label3.autoPinEdge(toSuperviewEdge: .trailing, withInset: 16)
        label3.autoAlignAxis(toSuperviewAxis: .vertical)
        
        view.addSubview(buttonDone)
        buttonDone.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(inset: 16), excludingEdge: .top)
        
        buttonDone.addTarget(self, action: #selector(buttonDoneDidTouch), for: .touchUpInside)
    }
    
    @objc func buttonDoneDidTouch() {
        do {
            try KeychainManager.save([
                Config.settingStepKey: CurrentUserSettingStep.backUpICloud.rawValue
            ])
            
            boardingNextStep()
        } catch {
            showError(error)
        }
    }
}
