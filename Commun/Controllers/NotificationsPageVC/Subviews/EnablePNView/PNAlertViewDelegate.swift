//
//  EnablePNViewDelegate.swift
//  Commun
//
//  Created by Chung Tran on 2/24/20.
//  Copyright © 2020 Commun Limited. All rights reserved.
//

import Foundation

protocol PNAlertViewDelegate: class {
    var pnAlertViewShowed: Bool {get}
    func clearPNAlertView()
    func showPNAlertView()
}

extension PNAlertViewDelegate {
    var notificationAlertLastTimeShowedKey: String {
        "notificationAlertLastTimeShowedKey"
    }
    
    var notificationAlertReAskAfterKey: String {
        "notificationAlertReAskAfterKey"
    }
    
    func closeButtonDidTouch(enablePNView: PNAlertView) {
        // save last time closing message
        UserDefaults.standard.set(Date(), forKey: notificationAlertLastTimeShowedKey)
        
        // check if reasked
        let reAskAfter = UserDefaults.standard.integer(forKey: notificationAlertReAskAfterKey)
        
        if reAskAfter == 0 {
            // reask after 1 months
            UserDefaults.standard.set(1, forKey: notificationAlertReAskAfterKey)
        } else if reAskAfter == 1 {
            // reask after 3 months
            UserDefaults.standard.set(3, forKey: notificationAlertReAskAfterKey)
        } else if reAskAfter == 3 {
            // stop asking
            UserDefaults.standard.set(-1, forKey: notificationAlertReAskAfterKey)
        }
        
        clearPNAlertView()
    }
    
    func openIOSSettingsButtonDidTouch(enablePNView: PNAlertView) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                print("Settings opened: \(success)") // Prints true
            })
        }
    }
    
    func checkPNAuthorizationStatus() {
        // check if PN is enabled
        let current = UNUserNotificationCenter.current()

        current.getNotificationSettings(completionHandler: { (settings) in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // Notification permission has not been asked yet, go for it!
                } else if settings.authorizationStatus == .denied {
                    // Notification permission was previously denied, go to settings & privacy to re-enable
                    
                    if self.pnAlertViewShowed {return}
                    
                    // if user has closed the alert before
                    if let lastTimeShowed = UserDefaults.standard.date(forKey: self.notificationAlertLastTimeShowedKey)
                    {
                        let reAskAfter = UserDefaults.standard.integer(forKey: self.notificationAlertReAskAfterKey)
                        
                        // stop asking
                        if reAskAfter == -1 {
                            return
                        }
                        
                        let components = Calendar.current.dateComponents([.month], from: lastTimeShowed, to: Date())
                        if (components.month ?? 0) >= reAskAfter {
                            self.showPNAlertView()
                        }
                    } else {
                        self.showPNAlertView()
                    }
                    
                } else if settings.authorizationStatus == .authorized {
                    // Notification permission was already granted
                    if !self.pnAlertViewShowed {return}
                    self.clearPNAlertView()
                }
            }
        })
    }
}
