//
//  CommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import TTTAttributedLabel

protocol CommentCellDelegate: class {
    var replyingComment: ResponseAPIContentGetComment? {get set}
    var expandedIndexes: [Int] {get set}
    var tableView: UITableView! {get set}
    func cell(_ cell: CommentCell, didTapUpVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapDownVoteButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapReplyButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapSeeMoreButtonForComment comment: ResponseAPIContentGetComment)
    func cell(_ cell: CommentCell, didTapOnUserName userName: String)
    func cell(_ cell: CommentCell, didTapOnTag tag: String)
}

class CommentCell: UITableViewCell {
    // MARK: - Constants
    private let defaultContentFontSize: CGFloat = 13
    private let maxCharactersForReduction = 150
    
    // MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var embedView: UIView!
    @IBOutlet weak var embedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var leftPaddingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    var bag = DisposeBag()
    var expanded = false
    var themeColor = UIColor(hexString: "#6A80F5")!
    
    // MARK: - Methods
    override func prepareForReuse() {
        super.prepareForReuse()
        // reset disposebag
        bag = DisposeBag()
        
        // observe changge
        observeCommentChanged()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        // avatar's tapGesture
        let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(authorDidTouch(gesture:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapOnAvatar)
        
        // set textAttributes
        contentLabel.linkAttributes = [
            NSAttributedString.Key.foregroundColor: themeColor
        ]
        contentLabel.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Setup
    func setupFromComment(_ comment: ResponseAPIContentGetComment, expanded: Bool = false) {
        self.comment = comment
        self.expanded = expanded
        
        // if comment is a reply
        if comment.parent.comment != nil {
            leftPaddingConstraint.constant = 72
        } else {
            leftPaddingConstraint.constant = 16
        }
//        leftPaddingConstraint.constant = CGFloat((comment.nestedLevel - 1 > 2 ? 2 : comment.nestedLevel - 1) * 72 + 16)
        
        // avatar
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? comment.author?.userId ?? "U")
        
        // setContent
        setText(expanded: expanded)
        
        // Show media
        let embededResult = comment.content.embeds.first?.result
        
        if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            embedViewHeightConstraint.constant = 101
            embedView.trailingAnchor.constraint(equalTo: embedView.superview!.trailingAnchor, constant: -10).isActive = true
        } else {
            // TODO: Video
            embedViewHeightConstraint.constant = 0
            if let constraint = embedView.constraints.first(where: {$0.firstAttribute == .trailing}) {
                embedView.removeConstraint(constraint)
            }
        }
        
        #warning("change this number later")
        voteCountLabel.text = "\(comment.votes.upCount ?? 0)"
        
        upVoteButton.tintColor = comment.votes.hasUpVote ? themeColor: .lightGray
        downVoteButton.tintColor = comment.votes.hasDownVote ? themeColor: .lightGray
        
        timeLabel.text = Date.timeAgo(string: comment.meta.time)
    }
    
    func showPhoto(with url: URL) {
        embedView.removeSubviews()
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.addTapToViewer()
        
        embedView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: embedView.topAnchor, constant: 8).isActive = true
        imageView.bottomAnchor.constraint(equalTo: embedView.bottomAnchor, constant: -8).isActive = true
        imageView.leadingAnchor.constraint(equalTo: embedView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: embedView.trailingAnchor).isActive = true
        
        imageView.showLoading()
        
        imageView.sd_setImage(with: url) { [weak self] (image, _, _, _) in
            var image = image
            if image == nil {
                image = UIImage(named: "image-not-found")
                imageView.image = image
            }
            self?.hideLoading()
        }
    }
    
    func setText(expanded: Bool = false) {
        guard let content = comment?.content.body.full else {return}
        
        let userId = comment?.author?.username ?? comment?.author?.userId ?? "Unknown user"
        let mutableAS = NSMutableAttributedString(string: userId, attributes: [
            .font: UIFont.boldSystemFont(ofSize: defaultContentFontSize),
            .foregroundColor: themeColor,
            .link: "https://commun.com/@\(comment?.author?.userId ?? comment?.author?.username ?? "unknown-user")"
        ])
        
        mutableAS.append(NSAttributedString(string: " "))
        
        // If text is not so long or expanded
        if content.count < maxCharactersForReduction || expanded {
            let contentAS = NSAttributedString(string: content, attributes: [
                .font: UIFont.systemFont(ofSize: defaultContentFontSize)
            ])
            mutableAS.append(contentAS)
            mutableAS.resolveTags()
            mutableAS.resolveLinks()
            mutableAS.resolveMentions()
            contentLabel.text = mutableAS
            return
        }
        
        // If doesn't expanded
        let contentAS = NSAttributedString(
            string: String(content.prefix(maxCharactersForReduction - 3)),
            attributes: [
                .font: UIFont.systemFont(ofSize: defaultContentFontSize)
            ])
        mutableAS.append(contentAS)
        
        // add see more button
        mutableAS
            .normal("...")
            .append(
                NSAttributedString(
                    string: "see more".localized().uppercaseFirst,
                    attributes: [
                        .link: "seemore://",
                        .foregroundColor: themeColor
                ])
            )


        contentLabel.text = mutableAS
    }
    
    // MARK: - Observing
    func observeCommentChanged() {
        NotificationCenter.default.rx.notification(.init(rawValue: CommentControllerCommentDidChangeNotification))
            .subscribe(onNext: {notification in
                guard let newComment = notification.object as? ResponseAPIContentGetComment,
                    newComment == self.comment
                    else {return}
                self.setupFromComment(newComment, expanded: self.expanded)
            })
            .disposed(by: bag)
    }
}
