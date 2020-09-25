//
//  CreateCommunityFirstStepVC.swift
//  Commun
//
//  Created by Chung Tran on 9/25/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation
import RxCocoa

class CreateCommmunityFirstStepVC: BaseVerticalStackVC {
    let descriptionLimit = 500
    
    lazy var coverImageView = UIImageView(cornerRadius: 10, contentMode: .scaleAspectFill)
        .image(.placeholder)
        .whRatio(335/150)
    lazy var changeCoverButton = UIButton.changeCoverButton
        .onTap(self, action: #selector(chooseCoverButtonDidTouch))
    lazy var avatarImageView = MyAvatarImageView(size: 80)
        .border(width: 2, color: .appWhiteColor)
    lazy var changeAvatarButton = UIButton.changeAvatarButton
        .onTap(self, action: #selector(chooseAvatarButtonDidTouch))
    
    lazy var communityNameTextField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 17, weight: .semibold)
        return tf
    }()
    lazy var descriptionTextView: UITextView = {
        let tv = UITextView(forExpandable: ())
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 17, weight: .semibold)
        tv.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 44, right: 0)
        tv.textContainer.lineFragmentPadding = 0
        return tv
    }()
    
    lazy var textCountLabel = UILabel.with(textSize: 12, textColor: .appWhiteColor, textAlignment: .center)
    
    lazy var languageFlagImageView = UIImageView.circle(size: 32)
    lazy var languageDetailLabel = UILabel.with(textSize: 15, numberOfLines: 2)
    
    let languageRelay = BehaviorRelay<Language?>(value: nil)
    var didSetAvatar = false
    var didSetCover = false
    
    override func setUpArrangedSubviews() {
        super.setUpArrangedSubviews()
        // image wrappers
        let imagesWrapper = UIView(forAutoLayout: ())
        imagesWrapper.addSubview(coverImageView)
        coverImageView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .bottom)
        
        imagesWrapper.addSubview(changeCoverButton)
        changeCoverButton.autoPinEdge(.bottom, to: .bottom, of: coverImageView, withOffset: -10)
        changeCoverButton.autoPinEdge(.trailing, to: .trailing, of: coverImageView, withOffset: -10)
        
        imagesWrapper.addSubview(avatarImageView)
        avatarImageView.autoPinEdge(.top, to: .bottom, of: coverImageView, withOffset: -40)
        avatarImageView.autoAlignAxis(toSuperviewAxis: .vertical)
        avatarImageView.autoPinEdge(toSuperviewEdge: .bottom)
        
        imagesWrapper.addSubview(changeAvatarButton)
        changeAvatarButton.autoPinEdge(.trailing, to: .trailing, of: avatarImageView)
        changeAvatarButton.autoPinEdge(.bottom, to: .bottom, of: avatarImageView)
        
        // name
        let communityNameField = infoField(title: "community name".localized().uppercaseFirst, editor: communityNameTextField)
        
        // bio
        let descriptionField = infoField(title: "description".localized().uppercaseFirst + " (" + "optional".localized().uppercaseFirst + ")", editor: descriptionTextView)
        
        let textCountLabelWrapper: UIView = {
            let view = UIView(height: 24, backgroundColor: .appBlackColor, cornerRadius: 12)
            view.addSubview(textCountLabel)
            textCountLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
            textCountLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 8)
            textCountLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 8)
            return view
        }()
        
        descriptionField.addSubview(textCountLabelWrapper)
        textCountLabelWrapper.autoPinBottomAndTrailingToSuperView(inset: 10, xInset: 16)
        
        let languageField: UIView = {
            let view = UIView(backgroundColor: .appWhiteColor, cornerRadius: 10)
            let stackView = UIStackView(axis: .horizontal, spacing: 10, alignment: .center, distribution: .fill)
            let nextButton = UIButton.circleGray(imageName: "cell-arrow", imageEdgeInsets: UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4))
            nextButton.isUserInteractionEnabled = false
            
            stackView.addArrangedSubview(languageFlagImageView)
            stackView.addArrangedSubview(languageDetailLabel)
            stackView.addArrangedSubview(nextButton)
            
            view.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
            
            view.isUserInteractionEnabled = true
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(languageFieldDidTouch)))
            
            return view
        }()
        
        stackView.addArrangedSubview(imagesWrapper)
        stackView.addArrangedSubview(communityNameField)
        stackView.addArrangedSubview(descriptionField)
        stackView.addArrangedSubview(languageField)
        
        stackView.setCustomSpacing(30, after: imagesWrapper)
        stackView.setCustomSpacing(16, after: communityNameField)
        stackView.setCustomSpacing(16, after: descriptionField)
    }
    
    override func bind() {
        super.bind()
        // description count
        descriptionTextView.rx.text.orEmpty
            .map {$0.count}
            .subscribe(onNext: { (count) in
                self.textCountLabel.text = "\(count)/\(self.descriptionLimit)"
                self.textCountLabel.superview?.backgroundColor = count > self.descriptionLimit ? .appRedColor : .appBlackColor
                self.textCountLabel.textColor = count > self.descriptionLimit ? .white : .appWhiteColor
            })
            .disposed(by: disposeBag)
        
        languageRelay
            .subscribe(onNext: { (language) in
                guard let language = language else {
                    self.languageFlagImageView.isHidden = true
                    self.languageDetailLabel.text = "language".localized().uppercaseFirst
                    self.languageDetailLabel.textColor = .appGrayColor
                    return
                }
                self.languageFlagImageView.isHidden = false
                self.languageFlagImageView.image = UIImage(named: "flag.\(language.code)")
                self.languageDetailLabel.attributedText = NSMutableAttributedString()
                    .text(language.name.uppercaseFirst, size: 15, weight: .medium)
                    .text("\n")
                    .text((language.name + " language").localized().uppercaseFirst, size: 12, weight: .medium, color: .appGrayColor)
                    
            })
            .disposed(by: disposeBag)
    }
    
    private func infoField(title: String, editor: UITextEditor) -> UIView {
        let stackView = UIStackView(axis: .vertical, spacing: 8, alignment: .leading, distribution: .fill)
        let titleLabel = UILabel.with(text: title, textSize: 12, weight: .medium, textColor: .appGrayColor)
        
        stackView.addArrangedSubviews([titleLabel, editor])
        editor.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -32)
            .isActive = true
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 7, trailing: 16)
        
        let field = UIView(cornerRadius: 10)
        field.backgroundColor = .appWhiteColor
        field.borderColor = .appLightGrayColor
        field.borderWidth = 1
        field.addSubview(stackView)
        stackView.autoPinEdgesToSuperviewEdges()
        return field
    }
    
    @objc func chooseCoverButtonDidTouch() {
        showCoverImagePicker { (image) in
            self.coverImageView.image = image
            self.didSetCover = true
        }
    }
    
    @objc func chooseAvatarButtonDidTouch() {
        // On updating
        let chooseAvatarVC = ProfileChooseAvatarVC.fromStoryboard("ProfileChooseAvatarVC", withIdentifier: "ProfileChooseAvatarVC")
        self.present(chooseAvatarVC, animated: true, completion: nil)
        
        chooseAvatarVC.viewModel.didSelectImage
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { (image) in
                self.avatarImageView.image = image
                self.didSetAvatar = true
            })
            .disposed(by: disposeBag)
    }
    
    @objc func languageFieldDidTouch() {
        UIView.performWithoutAnimation {
            self.view.endEditing(true)
        }
        
        let vc = CMLanguagesVC()
        vc.languageDidSelect = { language in
            vc.navigationController?.dismiss(animated: true, completion: nil)
            self.languageRelay.accept(language)
        }
        let navVC = SwipeNavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
}
