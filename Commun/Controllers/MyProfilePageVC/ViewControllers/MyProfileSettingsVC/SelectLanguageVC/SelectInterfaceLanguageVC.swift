//
//  SelectLanguageVC.swift
//  Commun
//
//  Created by Chung Tran on 11/1/19.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import Localize_Swift

class SelectInterfaceLanguageVC: CMLanguagesVC {
    override var supportedLanguages: [Language] {
        super.supportedLanguages.filter {$0.isSupportedInterfaceLanguage == true}
    }
    
    // MARK: - Methods
    override func setUp() {
        super.setUp()
        // get current language
        chooseCurrentLanguage()
    }
    
    private func chooseCurrentLanguage() {
        let langs: [Language] = languages.value.map { lang in
            var lang = lang
            lang.isCurrentInterfaceLanguage = lang.code == Localize.currentLanguage()
            return lang
        }
        languages.accept(langs)
    }
    
    override func modelSelected(item: Language) {
        let language = item
        if language.isCurrentInterfaceLanguage == true {return}
        self.showActionSheet(
            title: "would you like to change the application's language to".localized().uppercaseFirst + " " + (language.name + " language").localized().uppercaseFirst + "?",
            actions: [
                UIAlertAction(
                    title: "change to".localized().uppercaseFirst + " " + (language.name + " language").localized().uppercaseFirst,
                    style: .default,
                    handler: { _ in
                        Localize.setCurrentLanguage(language.code)
                        self.chooseCurrentLanguage()
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = SplashVC()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            appDelegate.tabBarVC = TabBarVC()
                            appDelegate.changeRootVC(appDelegate.tabBarVC)
                        }
                    }
                )
            ])
    }
}
