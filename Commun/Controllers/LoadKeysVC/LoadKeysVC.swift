//
//  LoadKeysVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 12/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoadKeysVC: UIViewController {
    // MARK: - Properties
    var viewModel: LoadKeysViewModel?
    let disposeBag = DisposeBag()
    
    
    // MARK: - IBOutlets
    @IBOutlet weak var textLabel1: UILabel! {
        didSet {
            self.textLabel1.tune(withText:      "Master key has been generated".localized(),
                                 hexColors:     blackWhiteColorPickers,
                                 font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                 alignment:     .center,
                                 isMultiLines:  false)
        }
    }
    
    @IBOutlet weak var textLabel2: UILabel! {
        didSet {
            self.textLabel2.tune(withText:      "You need Master Key".localized(),
                                 hexColors:     darkGrayishBluePickers,
                                 font:          UIFont(name: "SFProText-Regular", size: 17.0 * Config.heightRatio),
                                 alignment:     .center,
                                 isMultiLines:  true)
        }
    }
    
    
    @IBOutlet weak var downloadKeysButton: UIButton! {
        didSet {
            self.downloadKeysButton.tune(withTitle:     "Download".localized(),
                                         hexColors:     [whiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers, lightGrayWhiteColorPickers],
                                         font:          UIFont(name: "SFProText-Semibold", size: 17.0 * Config.heightRatio),
                                         alignment:     .center)
            
            self.downloadKeysButton.layer.cornerRadius = 8.0 * Config.heightRatio
            self.downloadKeysButton.clipsToBounds = true
        }
    }
    
    @IBOutlet var heightsCollection: [NSLayoutConstraint]! {
        didSet {
            self.heightsCollection.forEach({ $0.constant *= Config.heightRatio })
        }
    }

    
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeActions()
    }

    func makeActions() {
        downloadKeysButton.rx.tap.subscribe(onNext: { _ in
            self.viewModel!.saveKeys().subscribe(onNext: { flag in
                if flag {
                    UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
                    self.present(TabBarVC(), animated: true, completion: nil)
                } else {
                    self.showAlert(title: "Error".localized(), message: "Something went wrong")
                }
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
}
