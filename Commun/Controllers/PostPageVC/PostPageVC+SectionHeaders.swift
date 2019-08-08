//
//  PostPageVC+SectionHeaders.swift
//  Commun
//
//  Created by Chung Tran on 20/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC: UITableViewDelegate {
    fileprivate var needHideHeader: Bool {
        return viewModel.fetcher.reachedTheEnd || viewModel.comments.value.count == 0 || (viewModel.comments.value.count == viewModel.post.value!.stats.commentsCount)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if needHideHeader {return 0}
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if needHideHeader {return nil}
        
        let view = UIView()
        let header = UIButton(type: .system)
        header.setTitle("Load more comments".localized() + "...", for: .normal)
        
        view.addSubview(header)
        header.translatesAutoresizingMaskIntoConstraints = false
        
        header.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        header.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        header.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        header.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        
        header.addTarget(self, action: #selector(loadMore(sender:)), for: .touchUpInside)
        
        viewModel.loadingHandler = {
            header.setTitle("Loading".localized() + "...", for: .normal)
            header.isEnabled = false
        }
        
        viewModel.fetchNextErrorHandler = {error in
            header.setTitle("There is an error occurred".localized() + ". " + "Try again?".localized(), for: .normal)
            header.isEnabled = true
        }
        
        viewModel.listEndedHandler = {
            header.setTitle(nil, for: .normal)
            header.isEnabled = false
        }
        
        viewModel.fetchNextCompleted = {
            header.setTitle("Load more comments".localized() + "...", for: .normal)
            header.isEnabled = true
        }
        
        return view

    }
    
    @objc func loadMore(sender: UIButton) {
        viewModel.fetchNext()
    }
}
