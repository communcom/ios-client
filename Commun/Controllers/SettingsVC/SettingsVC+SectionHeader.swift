//
//  SettingsVC+SectionHeader.swift
//  Commun
//
//  Created by Chung Tran on 18/07/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation

extension SettingsVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0, 1, 2:
            return 56
        default:
            return 0
        }
    }
    
    func createHeaderViews() {
        var views = [UIView]()
        
        for section in 0..<3 {
            let view = UIView()
            view.backgroundColor = .white
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 56))
            label.font = .boldSystemFont(ofSize: 22)
            label.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(label)
            
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        
            switch section {
            case 0:
                label.text = "general".localized().uppercaseFirst
            case 1:
                label.text = "notifications".localized().uppercaseFirst
                let switcher = UISwitch(frame: CGRect.zero)
                switcher.translatesAutoresizingMaskIntoConstraints = false
                switcher.onTintColor = .appMainColor
                switcher.isOn = viewModel.notificationOn.value
                
                viewModel.optionsPushShow
                    .filter {$0 != nil}
                    .filter {
                        !$0!.upvote &&
                            !$0!.downvote &&
                            !$0!.transfer &&
                            !$0!.reply &&
                            !$0!.mention &&
                            !$0!.reward &&
                            !$0!.curatorReward &&
                            !$0!.subscribe &&
                            !$0!.repost
                    }
                    .subscribe(onNext: {_ in
                        switcher.rx.isOn.onNext(false)
                        switcher.sendActions(for: .valueChanged)
                    })
                    .disposed(by: bag)
                
                switcher.rx.isOn
                    .skip(1)
                    .distinctUntilChanged()
                    .subscribe(onNext: {isOn in
                        self.viewModel.togglePushNotify(on: isOn)
                            .subscribe( onCompleted: {
                                if isOn {
                                    self.viewModel.getOptionsPushShow()
                                }
                            }, onError: {[weak self] (error) in
                                switcher.isOn = !switcher.isOn
                                self?.showError(error)
                            })
                            .disposed(by: self.bag)
                    })
                    .disposed(by: bag)
                
                view.addSubview(switcher)
                
                switcher.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                switcher.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
            case 2:
                label.text = "Passwords".localized()
                viewModel.showKey
                    .subscribe(onNext: {show in
                        if show {
                            let button = UIButton(frame: CGRect.zero)
                            button.translatesAutoresizingMaskIntoConstraints = false
                            button.setTitleColor(.appMainColor, for: .normal)
                            button.setTitle("Back up".localized(), for: .normal)
                            view.addSubview(button)
                            
                            button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
                            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
                            button.addTarget(self, action: #selector(self.btnBackUpDidTouch), for: .touchUpInside)
                        } else {
                            if let button = view.subviews.first(where: {$0 is UIButton}) {
                                button.removeFromSuperview()
                            }
                        }
                    })
                    .disposed(by: bag)
            default:
                label.text = ""
            }
            
            views.append(view)
        }
        
        sectionHeaders = views
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionHeaders[section]
    }
    
    @objc func btnBackUpDidTouch() {
        let vc = controllerContainer.resolve(KeysVC.self)!
        vc.onBoarding = false
        vc.completion = {
            self.navigationController?.popToViewController(self, animated: true)
        }
        self.show(vc, sender: nil)
    }
}
