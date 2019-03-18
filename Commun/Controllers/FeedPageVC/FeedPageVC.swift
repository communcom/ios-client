//
//  FeedPageVC.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 15/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//

import UIKit

class FeedPageVC: UIViewController {

    var viewModel = FeedPageViewModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentioView: Segmentio!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .white
        
        tableView.register(UINib(nibName: "PostCardCell", bundle: nil), forCellReuseIdentifier: "PostCardCell")
        tableView.register(UINib(nibName: "PostCardMediaCell", bundle: nil), forCellReuseIdentifier: "PostCardMediaCell")
        tableView.register(UINib(nibName: "EditorWidgetCell", bundle: nil), forCellReuseIdentifier: "EditorWidgetCell")
        
        let searchBar = UISearchBar(frame: self.view.bounds)
        searchBar.placeholder = "Search"
        self.navigationItem.titleView = searchBar
        
        let searchField: UITextField = searchBar.value(forKey: "searchField") as! UITextField
        searchField.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9607843137, blue: 0.9803921569, alpha: 1)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.rowHeight = UITableView.automaticDimension
        
        let indicator = SegmentioIndicatorOptions(type: .bottom,
                                                  ratio: 1,
                                                  height: 2,
                                                  color: #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1))
        let states = SegmentioStates(
            defaultState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont(name: "SF Pro Text", size: 15) ?? UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: #colorLiteral(red: 0.6078431373, green: 0.6235294118, blue: 0.6352941176, alpha: 1)
            ),
            selectedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont(name: "SF Pro Text", size: 15) ?? UIFont.systemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            ),
            highlightedState: SegmentioState(
                backgroundColor: .clear,
                titleFont: UIFont(name: "SF Pro Text", size: 15) ?? UIFont.boldSystemFont(ofSize: UIFont.smallSystemFontSize),
                titleTextColor: .black
            )
        )
        
        let options = SegmentioOptions(backgroundColor: .white,
                                       segmentPosition: .dynamic,
                                       scrollEnabled: false,
                                       indicatorOptions: indicator,
                                       horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom,
                                                                                                       height: 0,
                                                                                                       color: #colorLiteral(red: 0.4235294118, green: 0.5137254902, blue: 0.9294117647, alpha: 1)),
                                       verticalSeparatorOptions: nil,
                                       imageContentMode: .scaleAspectFit,
                                       labelTextAlignment: .center,
                                       labelTextNumberOfLines: 0,
                                       segmentStates: states,
                                       animationDuration: 0.5)
        
        segmentioView.setup(content: [SegmentioItem(title: "All", image: nil), SegmentioItem(title: "My Feed", image: nil)],
                            style: SegmentioStyle.onlyLabel,
                            options: options)
        
        segmentioView.selectedSegmentioIndex = 0
        
    }

}
