//
//  TestViewController.swift
//  CommunShare
//
//  Created by Sergey Monastyrskiy on 30.01.2020.
//  Copyright © 2020 Sergey Monastyrskiy. All rights reserved.
//
//  https://stackoverflow.com/questions/47028285/is-it-possible-to-open-full-view-controller-in-share-extension-instead-of-popup
//

import UIKit

class TestViewController: UIViewController {
    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        self.navigationItem.title = "Share this"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(cancelButtonTapped))
    }
    
    
    // MARK: - Custom Functions
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        // Dismiss
        UIView.animate(withDuration: 0.20, animations: {
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    
    
    // MARK: - Actions
    @objc func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
}
