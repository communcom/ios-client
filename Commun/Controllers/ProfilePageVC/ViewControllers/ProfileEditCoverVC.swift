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
        
        // Bind avatar
        avatarImage.observeCurrentUserAvatar()
            .disposed(by: bag)
    }
    
    // MARK: - binding
    func bindProfile() {
        profile
            .filter {$0 != nil}
            .map {$0!}
            .subscribe(onNext: { profile in
                // user name
                self.userNameLabel.text = profile.username
                
                // join date
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .long
                let dateString = dateFormatter.string(from: Date.from(string: profile.registration.time))
                self.joinedDateLabel.text = String(format: "%@ %@", "joined".localized().uppercaseFirst, dateString)
            })
            .disposed(by: bag)
    }
    
    // MARK: - Actions
    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonDidTap(_ sender: Any) {
        //scale image to fit the imageView's width (maintaining aspect ratio), but allow control over the image's Y position
        UIGraphicsBeginImageContext(coverImage.bounds.size);
        coverImage.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        didSelectImage.onNext(image ?? coverImage.image!)
    }
}
