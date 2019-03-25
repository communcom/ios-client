//
//  FeedPageVC+UITableViewDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

extension FeedPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row >= cells.count - 5 {
            viewModel.loadFeed()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let postPageVC = controllerContainer.resolve(PostPageVC.self) {
            postPageVC.viewModel.postForRequest = viewModel.items.value[indexPath.row]
            present(postPageVC, animated: true, completion: nil)
        } else {
            showAlert(title: "Error", message: "Something went wrong")
        }
        
    }
}
