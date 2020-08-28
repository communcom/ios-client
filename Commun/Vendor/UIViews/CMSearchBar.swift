//
//  CMSearchBar.swift
//  Commun
//
//  Created by Chung Tran on 6/18/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol CMSearchBarDelegate: class {
    func cmSearchBar(_ searchBar: CMSearchBar, searchWithKeyword keyword: String)
    func cmSearchBarDidBeginSearching(_ searchBar: CMSearchBar)
    func cmSearchBarDidEndSearching(_ searchBar: CMSearchBar)
    func cmSearchBarDidCancelSearching(_ searchBar: CMSearchBar)
}

extension CMSearchBarDelegate where Self: BaseViewController {
    func cmSearchBarDidBeginSearching(_ searchBar: CMSearchBar) {
        navigationController?.setNavigationBarHidden(true, animated: true)
        view.layoutIfNeeded()
    }
    
    func cmSearchBarDidEndSearching(_ searchBar: CMSearchBar) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        view.layoutIfNeeded()
    }
    
    func cmSearchBarDidCancelSearching(_ searchBar: CMSearchBar) {
        searchBar.clear()
    }
}

class CMSearchBar: MyView {
    // MARK: - Properties
    var placeholder = "search".localized().uppercaseFirst {
        didSet {
            textField.placeholder = placeholder
        }
    }
    var textFieldBgColor = UIColor.appLightGrayColor {
        didSet {
            textField.backgroundColor = textFieldBgColor
        }
    }
    weak var delegate: CMSearchBarDelegate?
    
    // MARK: - Subviews
    private lazy var stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .fill, distribution: .fill)
    
    private lazy var textField: UITextField = {
        let textField = UITextField(backgroundColor: textFieldBgColor, placeholder: placeholder, showClearButton: true)
        
        // textField's leftView
        let magnifyingIconSize: CGFloat = 14
        let leftView = UIView(width: 34, height: magnifyingIconSize)
        let imageView = UIImageView(width: magnifyingIconSize, height: magnifyingIconSize, imageNamed: "search")
        leftView.addSubview(imageView)
        imageView.autoCenterInSuperview()
        
        textField.leftView = leftView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(label: "cancel".localized().uppercaseFirst, textColor: .appMainColor)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.addTarget(self, action: #selector(cancelButtonDidTouch), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initializers
    init(textFieldBackgroundColor: UIColor = .appLightGrayColor) {
        super.init(frame: .zero)
        configureForAutoLayout()
        autoSetDimension(.height, toSize: 35)
        textFieldBgColor = textFieldBackgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func commonInit() {
        super.commonInit()
        stackView.addArrangedSubviews([textField, cancelButton])
        
        addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        
        cancelButton.isHidden = true
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if height > 0 {
            textField.cornerRadius = height / 2
        }
    }
    
    fileprivate func showCancelButton(_ show: Bool = true) {
        if cancelButton.isHidden != show {return}
        cancelButton.isHidden = !show
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 1, options: [], animations: {
            self.stackView.layoutIfNeeded()
        }, completion: nil)
    }
    
    func clear() {
        textField.text = ""
        textField.sendActions(for: .editingChanged)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonDidTouch() {
        textField.resignFirstResponder()
        delegate?.cmSearchBarDidCancelSearching(self)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(triggerSearch), object: nil)
        perform(#selector(triggerSearch), with: nil, afterDelay: 0.3)
    }
    
    @objc private func triggerSearch() {
        delegate?.cmSearchBar(self, searchWithKeyword: textField.text ?? "")
    }
}

extension CMSearchBar: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showCancelButton()
        delegate?.cmSearchBarDidBeginSearching(self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        showCancelButton(false)
        delegate?.cmSearchBarDidEndSearching(self)
    }
}
