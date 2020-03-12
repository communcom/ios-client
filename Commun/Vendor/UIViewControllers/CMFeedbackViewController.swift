//
//  CMFeedbackViewController.swift
//  Commun
//
//  Created by Sergey Monastyrskiy on 04.03.2020.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import UIKit
import RxSwift

class CMFeedbackViewController: UIViewController {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    lazy var closeButton = UIButton.close()
    let sendButton = CommunButton.default(height: 50.0, label: "send".localized().uppercaseFirst, isDisabled: true)
   
    let titleLabel = UILabel.init(text: "feedback".localized().uppercaseFirst,
                                  font: .systemFont(ofSize: 15.0, weight: .bold),
                                  numberOfLines: 1,
                                  color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))

    lazy var textView: UITextView = {
        let textViewInstance = UITextView()
        textViewInstance.placeholder = "text view feedback placeholder".localized().uppercaseFirst
        textViewInstance.tune(with: .black, font: .systemFont(ofSize: 17.0, weight: .regular), alignment: .left)
        
        return textViewInstance
    }()
    
    // MARK: - Class Initialization
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.bind()
        self.setUp()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Logger.log(message: "Success", event: .severe)
    }

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Custom Functions
    private func bind() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)

        self.textView.rx.didChange
            .map { self.textView.text }
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { text in
                self.sendButton.isDisabled = text.count == 0 || text == "\n"
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setUp() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        view.addSubview(closeButton)
        closeButton.autoPinTopAndTrailingToSuperView(inset: 15.0, xInset: 15.0)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        view.addSubview(titleLabel)
        titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
        titleLabel.autoAlignAxis(.horizontal, toSameAxisOf: closeButton)

        view.addSubview(textView)
        textView.autoPinEdgesToSuperviewSafeArea(with: UIEdgeInsets(horizontal: 30.0, vertical: 108.0), excludingEdge: .bottom)

        view.addSubview(sendButton)
        sendButton.autoAlignAxis(toSuperviewAxis: .vertical)
        sendButton.autoPinEdge(toSuperviewEdge: .leading, withInset: 15.0)
        sendButton.autoPinEdge(toSuperviewEdge: .trailing, withInset: 15.0)
        sendButton.autoPinEdge(.top, to: .bottom, of: textView, withOffset: 15.0)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        
        let keyboardViewV = KeyboardLayoutConstraint(item: view!.safeAreaLayoutGuide,
                                                     attribute: .bottom,
                                                     relatedBy: .equal,
                                                     toItem: sendButton,
                                                     attribute: .bottom,
                                                     multiplier: 1.0,
                                                     constant: 10.0)
        keyboardViewV.observeKeyboardHeight()
        view.addConstraint(keyboardViewV)
    }
    
    private func checkValues() -> Bool {
        guard !textView.text.isEmpty else {
            self.hintView?.display(inPosition: sendButton.frame.origin, withType: .enterText, completion: {})
            return false
        }
        
        return true
    }
    
    // MARK: - Actions
    @objc func closeButtonTapped( _ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func sendButtonTapped( _ sender: UIButton) {
        guard checkValues() else { return }

        self.dismiss(animated: true, completion: {
            AnalyticsManger.shared.sendFeedback(message: self.textView.text)
        })
    }
    
    @objc func viewTapped( _ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
