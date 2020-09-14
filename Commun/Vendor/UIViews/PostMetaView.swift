//
//  PostTitleView.swift
//  Commun
//
//  Created by Chung Tran on 10/2/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import RxSwift

protocol PostMetaViewDelegate: class {
    var post: ResponseAPIContentGetPost? {get}
    func postMetaViewRewardButtonDidTouch()
}

extension PostMetaViewDelegate where Self: PostCell {
    func postMetaViewRewardButtonDidTouch() {
        guard let post = post else {return}
        let vc = RewardsExplanationVC(post: post)
        parentViewController?.present(vc, animated: true, completion: nil)
    }
}

extension PostMetaViewDelegate where Self: BaseViewController {
    func postMetaViewRewardButtonDidTouch() {
        guard let post = post else {return}
        let vc = RewardsExplanationVC(post: post)
        present(vc, animated: true, completion: nil)
    }
}

class PostMetaView: CMMetaView {
    // MARK: - Enums
    class TapGesture: UITapGestureRecognizer {
        var community: ResponseAPIContentGetCommunity?
        var author: ResponseAPIContentGetProfile?
    }
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    private var mosaic: ResponseAPIRewardsGetStateBulkMosaic?
    var showMosaic: Bool = true {
        didSet {
            stateButton.isHidden = !showMosaic
        }
    }
    weak var delegate: PostMetaViewDelegate?

    // MARK: - Subviews
    lazy var stateButtonLabel = UILabel.with(textSize: 12, weight: .semibold, textColor: .white)

    lazy var stateButton: UIView = {
        let view = UIView(height: 30, backgroundColor: .appMainColor, cornerRadius: 30 / 2)
        let imageView = UIImageView(forAutoLayout: ())
        imageView.image = UIImage(named: "icon-post-state-default")
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 20/18.95)
            .isActive = true
        imageView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 0), excludingEdge: .trailing)
        
        view.addSubview(stateButtonLabel)
        stateButtonLabel.autoPinEdge(.leading, to: .trailing, of: imageView, withOffset: 5)
        stateButtonLabel.autoAlignAxis(toSuperviewAxis: .horizontal)
        stateButtonLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 10)
        stateButtonLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        view.isUserInteractionEnabled = true
        view.tag = 0
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(stateButtonTapped(_:))))
        
        view.widthAnchor.constraint(lessThanOrEqualToConstant: .adaptive(width: 208.0)).isActive = true
        
        return view
    }()

    // MARK: - Properties
    var isUserNameTappable = true
    var isCommunityNameTappable = true

    // MARK: - Custom Functions
    override func commonInit() {
        super.commonInit()
        
        stackView.addArrangedSubview(stateButton)
        stackView.setCustomSpacing(4, after: labelStackView)
        stateButton.isHidden = true
        
        // currency changed
        UserDefaults.standard.rx.observe(String.self, Config.currentRewardShownSymbol)
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { _ in
                self.setMosaic()
            })
            .disposed(by: disposeBag)
    }
    
    func setUp(post: ResponseAPIContentGetPost) {
        setUp(with: post.community, author: post.author, creationTime: post.meta.creationTime)
        self.mosaic = post.mosaic
        if showMosaic {
            setMosaic()
        }
    }
    
    func setUp(comment: ResponseAPIContentGetComment) {
        setUp(with: comment.community, author: comment.author, creationTime: comment.meta.creationTime)
    }
    
    func setUp(with community: ResponseAPIContentGetCommunity?, author: ResponseAPIContentGetProfile?, creationTime: String) {
        let isMyFeed = community?.communityId == "FEED"
        avatarImageView.setAvatar(urlString: isMyFeed ? author?.avatarUrl : community?.avatarUrl)
        titleLabel.text = isMyFeed ? (author?.personal?.fullName ?? author?.username) : community?.name
        
        subtitleLabel.attributedText = NSMutableAttributedString()
            .text(Date.timeAgo(string: creationTime) + " • ", size: 12, weight: .semibold, color: .appGrayColor)
            .text(isMyFeed ? (community?.name ?? community?.communityId ?? "") : (author?.personal?.fullName ?? author?.username ?? author?.userId ?? ""), size: 12, weight: .semibold, color: .appMainColor)
        
        // add gesture
        if isUserNameTappable {
            let tap = TapGesture(target: self, action: isMyFeed ? #selector(communityNameTapped(_:)) : #selector(userNameTapped(_:)))
            tap.community = community
            tap.author = author
            subtitleLabel.isUserInteractionEnabled = true
            subtitleLabel.addGestureRecognizer(tap)
        }
        
        if isCommunityNameTappable {
            let tapLabel = TapGesture(target: self, action: isMyFeed ? #selector(userNameTapped(_:)) : #selector(communityNameTapped(_:)))
            let tapAvatar = TapGesture(target: self, action: isMyFeed ? #selector(userNameTapped(_:)) : #selector(communityNameTapped(_:)))
            tapLabel.author = author
            tapLabel.community = community
            tapAvatar.author = author
            tapAvatar.community = community

            avatarImageView.isUserInteractionEnabled = true
            avatarImageView.addGestureRecognizer(tapAvatar)
            titleLabel.isUserInteractionEnabled = true
            titleLabel.addGestureRecognizer(tapLabel)
        }
    }
    
    private func setMosaic() {
        guard let mosaicItem = mosaic, mosaicItem.isRewarded else {
            stateButton.isHidden = true
            return
        }
        
        stateButton.isHidden = false
        
        let isRewardState = mosaicItem.isClosed
        
        var value = ""
        
        if !isRewardState {
            value = "in top".localized().uppercaseFirst + ": "
        }
        
        value += mosaicItem.formatedRewardsValue
        
        stateButtonLabel.text = value
        stateButton.tag = Int(isRewardState.int)
    }
    
    // MARK: - Actions
    @objc func userNameTapped(_ sender: TapGesture) {
        guard let userId = sender.author?.userId else {return}
        if parentViewController?.isModal == true,
            let parentVC = parentViewController?.presentingViewController
        {
            var vcToShow = parentVC
            if let tabBar = parentVC as? TabBarVC {
                vcToShow = tabBar.selectedViewController!
            }
            parentViewController?.dismiss(animated: true, completion: {
                vcToShow.showProfileWithUserId(userId)
            })
            return
        }
        parentViewController?.showProfileWithUserId(userId)
    }
    
    @objc func communityNameTapped(_ sender: TapGesture) {
        guard let communityId = sender.community?.communityId else {return}
        if parentViewController?.isModal == true,
            let parentVC = parentViewController?.presentingViewController
        {
            var vcToShow = parentVC
            if let tabBar = parentVC as? TabBarVC {
                vcToShow = tabBar.selectedViewController!
            }
            parentViewController?.dismiss(animated: true, completion: {
                vcToShow.showCommunityWithCommunityId(communityId)
            })
            return
        }
        parentViewController?.showCommunityWithCommunityId(communityId)
    }
    
    @objc func stateButtonTapped(_ gesture: UITapGestureRecognizer) {
        delegate?.postMetaViewRewardButtonDidTouch()
    }
}
