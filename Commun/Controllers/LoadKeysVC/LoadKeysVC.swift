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
import PDFReader
import CyberSwift

class LoadKeysVC: UIViewController {
    // MARK: - Properties
    var viewModel: LoadKeysViewModel?
    let disposeBag = DisposeBag()

    var pdfViewController: PDFViewController?

    
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
            self.showIndetermineHudWithMessage("Saving keys".localized())
            self.viewModel!.saveKeys().subscribe(onNext: { flag in
                self.hideHud()
                if flag {
                    // Display PDF-file
                    if let pdfDocument = KeychainManager.loadPDFDocument() {
                        self.displayPDF(document: pdfDocument)
                    }
                } else {
                    self.showGeneralError()
                }
            }, onError: {_ in
                self.hideHud()
                self.showGeneralError()
            }).disposed(by: self.disposeBag)
        }).disposed(by: disposeBag)
    }
}


// MARK: - PDF utilities
extension LoadKeysVC {
    func displayPDF(document: PDFDocument) {
        let closeButton = UIBarButtonItem(title:    "Close".localized(),
                                          style:    .done,
                                          target:   self,
                                          action:   #selector(didClose(sender:)))
        
        self.pdfViewController = PDFViewController.createNew(with:          document,
                                                             title:         "User keys info".localized(),
                                                             actionStyle:   .activitySheet,
                                                             backButton:    closeButton)
        
        self.pdfViewController?.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.pushViewController(self.pdfViewController ?? UIViewController(), animated: true)
    }
    
    @objc func didClose(sender: UIBarButtonItem) {
        self.pdfViewController?.navigationController?.popViewController(animated: true)
        
        // Save keys
        UserDefaults.standard.set(true, forKey: Config.isCurrentUserLoggedKey)
        WebSocketManager.instance.authorized.accept(true)
    }
}
