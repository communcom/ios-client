//
//  PostPageVC+SectionHeaders.swift
//  Commun
//
//  Created by Chung Tran on 20/06/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import Foundation

extension PostPageVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if viewModel.fetcher.reachedTheEnd {return 0}
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if viewModel.fetcher.reachedTheEnd {return nil}
        
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
        
        return view

    }
    
    @objc func loadMore(sender: UIButton) {
        viewModel.fetchNext()
    }
}
