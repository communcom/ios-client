//
//  CommentCell.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 24/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import RxSwift

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

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var contentLabel: TTTAttributedLabel!
    @IBOutlet weak var embedView: UIView!
    @IBOutlet weak var embedViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var leftPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightPaddingConstraint: NSLayoutConstraint!
    
    private let maxCharactersForReduction = 150
    
    var comment: ResponseAPIContentGetComment?
    var delegate: CommentCellDelegate?
    let bag = DisposeBag()
    
    var expanded = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        
        contentLabel.delegate = self
        
        let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(authorDidTouch(gesture:)))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapOnAvatar)
        
        let tapOnUserName = UITapGestureRecognizer(target: self, action: #selector(authorDidTouch(gesture:)))
        nameLabel.isUserInteractionEnabled = true
        nameLabel.addGestureRecognizer(tapOnUserName)
        
        observeCommentChanged()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupFromComment(_ comment: ResponseAPIContentGetComment, expanded: Bool = false) {
        self.comment = comment
        self.expanded = expanded
        
        // if comment is a reply
        if comment.parent.comment != nil {
            leftPaddingConstraint.constant = 72
            rightPaddingConstraint.constant = 16
        } else {
            leftPaddingConstraint.constant = 16
            rightPaddingConstraint.constant = 72
        }
//        leftPaddingConstraint.constant = CGFloat((comment.nestedLevel - 1 > 2 ? 2 : comment.nestedLevel - 1) * 72 + 16)
        
        setText(expanded: expanded)
        
        avatarImageView.setAvatar(urlString: comment.author?.avatarUrl, namePlaceHolder: comment.author?.username ?? comment.author?.userId ?? "U")
        nameLabel.text = comment.author?.username ?? comment.author?.userId
        timeLabel.text = Date.timeAgo(string: comment.meta.time)
        
        // Show media
        let embededResult = comment.content.embeds.first?.result
        
        if embededResult?.type == "photo",
            let urlString = embededResult?.url,
            let url = URL(string: urlString) {
            showPhoto(with: url)
            embedViewHeightConstraint.constant = 142
        } else {
            // TODO: Video
            embedViewHeightConstraint.constant = 0
        }
        
        #warning("change this number later")
        voteCountLabel.text = "\(comment.votes.upCount ?? 0)"
        
        setButton()
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
    
    func setButton() {
        // Handle button
        upVoteButton.setImage(UIImage(named: comment?.votes.hasUpVote == true ? "icon-up-selected" : "icon-up-default"), for: .normal)
        downVoteButton.setImage(UIImage(named: comment?.votes.hasDownVote == true ? "icon-down-selected" : "icon-down-default"), for: .normal)
    }
    
    func setText(expanded: Bool = false) {
        guard let content = comment?.content.body.full else {return}
        
        // If text is not so long
        if content.count < maxCharactersForReduction {
            contentLabel.text = content
            addLinksFromContent(content)
            return
        }
        
        // If text is long
        if expanded {
            contentLabel.text = content
            addLinksFromContent(content)
            return
        }
        
        // If doesn't expanded
        let text = NSMutableAttributedString()
            .normal(String(content.prefix(maxCharactersForReduction - 3)))
            .normal("...")
            .semibold("see more".localized().uppercaseFirst, color: .appMainColor)
        contentLabel.text = text
        contentLabel.addLinkToText("see more".localized().uppercaseFirst, toUrl: "seemore://")
    }
    
    func addLinksFromContent(_ content: String) {
        // Detect links
        addLinks(html: content)
        
        // tags and usernames
        contentLabel.highlightTagsAndUserNames()
    }
    
    func addLinks(html: String) {
        // Result
        var result = html
        var links = [(url: String, description: String)]()
        
        // Detect links
        let types = NSTextCheckingResult.CheckingType.link
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return
        }
        let matches = detector.matches(in: result, options: .reportCompletion, range: NSMakeRange(0, result.count))
        
        var originals = matches.map {
            result.nsString.substring(with: $0.range)
        }
        
        for (index, match) in matches.enumerated() {
            guard let urlString = match.url?.absoluteString else {continue}
            
            if let regex1 = try? NSRegularExpression(pattern: "\\!?\\[.*\\]\\(\(NSRegularExpression.escapedPattern(for: originals[index]))\\)", options: .caseInsensitive) {
                
                for embededString in regex1.matchedStrings(in: result) {
                    var description: String?
                    
                    if let match = embededString.range(of: "\\[.*\\]", options: .regularExpression) {
                        description = String(embededString[match]).replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                    }
                    
                    if let description = description, description.count > 0 {
                        result = result.replacingOccurrences(of: embededString, with: description)
                        links.append((url: urlString, description: description))
                    } else {
                        result = result.replacingOccurrences(of: embededString, with: urlString)
                        links.append((url: urlString, description: urlString))
                    }
                }
            }
        }
        contentLabel.text = result
        for link in links {
            contentLabel.addLinkToText(link.description, toUrl: link.url)
        }
        
        for match in matches {
            guard let urlString = match.url?.absoluteString else {continue}
            contentLabel.addLinkToText(urlString)
        }
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
