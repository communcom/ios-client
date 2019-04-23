//
//  ProfileEditCoverVC.swift
//  Commun
//
//  Created by Chung Tran on 23/04/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CyberSwift

class ProfileEditCoverVC: UIViewController {
    @IBOutlet weak var coverImage: VerticalDraggableImageView!
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var joinedDateLabel: UILabel!
    
    var profile = BehaviorRelay<ResponseAPIContentGetProfile?>(value: nil)
    private let bag = DisposeBag()
    
    var didSelectImage = PublishSubject<UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Bind
        bindProfile()
    }
    
    // MARK: - binding
    func bindProfile() {
        profile
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { profile in
                // profile image
                if let avatarUrl = profile.personal.avatarUrl {
                    self.avatarImage.sd_setImage(with: URL(string: avatarUrl)) { (_, error, _, _) in
                        if (error != nil) {
                            // Placeholder image
                            self.avatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
                        }
                    }
                } else {
                    // Placeholder image
                    self.avatarImage.setImageWith(profile.username, color: #colorLiteral(red: 0.9997546077, green: 0.6376479864, blue: 0.2504218519, alpha: 1))
                }
                
                // user name
                self.userNameLabel.text = profile.username
                
                // join date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
                self.joinedDateLabel.text = ("Joined".localized() + " " + dateString)
            })
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        didSelectImage.onNext(coverImage.image!)
    }
}
