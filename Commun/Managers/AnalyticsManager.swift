//
//  AnalyticsManager.swift
//  Commun
//
//  Created by Artem Shilin on 19.12.2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//

import Foundation
import Amplitude_iOS
import FirebaseAnalytics
import AppsFlyerLib

class AnalyticsManger {
    typealias Properties = [String: Any]
    // MARK: - Singleton
    static let shared = AnalyticsManger()

    private init() {
        #if APPSTORE
            Amplitude.instance()?.initializeApiKey("38406204507945e0941d552f088204fb")
        #endif
    }

    // MARK: - Rate
    func sendFeedback(message: String) {
        sendEvent(name: "Feedback", props: ["message": message])
    }

    func showRate() {
        sendEvent(name: "Show Rate App")
    }

    func rate(isLike: Bool) {
        sendEvent(name: "Rate App", props: ["Is Like": isLike])
    }

    // MARK: - Launch
    func launchFirstTime() {
        sendEvent(name: "Launch first time")
    }

    func sessionStart() {
        sendEvent(name: "Session start")
    }

    func backgroundApp() {
        sendEvent(name: "Background")
    }

    func foregroundApp() {
        sendEvent(name: "Foreground")
    }

    // MARK: - Onboarding
    func onboadringOpenScreen(page: Int, tapSignIn: Bool = false) {
        var props: Properties? = ["sign_in": tapSignIn]
        if page == 4 {
            props = nil
        }
        sendEvent(name: "ONB \(page) screen opend", props: props)
    }

    func onboardingOpenScreen(_ number: Int) {
        sendEvent(name: "Open screen 0.1.\(number)")
    }

    func signUpButtonPressed() {
        sendEvent(name: "Click get started 0.3.1")
    }

    func registrationOpenScreen(_ number: Int) {
        sendEvent(name: "Open screen 1.1.\(number)")
    }

    func registrationWithGoogle() {
        sendEvent(name: "Google auth")
    }

    func registrationWithFacebook() {
        sendEvent(name: "Facebook auth")
    }

    func registrationWithAppale() {
        sendEvent(name: "Apple auth")
    }

    func signInButtonPressed() {
        sendEvent(name: "Click log in 0.1")
    }

    // MARK: - Sign UP
    func goToSingIn() {
        sendEvent(name: "Go to sign in")
    }

    func openRegistrationSelection() {
        sendEvent(name: "Open Sign Up")
    }

    func openGoogleSignUp() {
        sendEvent(name: "Open screen 1.2.1")
    }

    func getGoogleSignUpData() {
        sendEvent(name: "Google auth")
    }

    func getFacebookSignUpData() {
        sendEvent(name: "Open screen 1.2.1")
    }

    func openFacebookSignUp() {
        sendEvent(name: "Facebook auth")
    }

    func countrySelected(phoneCode: String, available: Bool) {
        sendEvent(name: "Country selected", props: [
            "phoneCode": phoneCode,
            "available": available
        ])
    }

    func PhoneNumberEntered() {
        sendEvent(name: "Phone number entered")
    }

    func smsCodeEntered() {
        sendEvent(name: "Sms code entered")
    }

    func smsCodeRight() {
        sendEvent(name: "Sms code right")
    }

    func smsCodeError() {
        sendEvent(name: "Sms code error")
    }

    func smsCodeResend() {
        sendEvent(name: "Sms code resend")
    }

    func userNameEntered() {
        sendEvent(name: "Username entered")
    }

    func userNameHelp() {
        sendEvent(name: "Username help")
    }

    func passwordCopy() {
        sendEvent(name: "Password copy")
    }

    func passwordBackuped() {
        sendEvent(name: "Password backuped")
    }

    func passwordNotBackuped(back: Bool) {
        sendEvent(name: "Password not backuped", props: ["answer": !back])
    }

    func activateFaceID(_ activate: Bool) {
        sendEvent(name: "FaceID/TouchID activated", props: ["answer": activate])
    }

    // MARK: - Sign IN
    func startQRScanner() {
        sendEvent(name: "ScanQR SI")
    }

    func scanQRStatus(success: Bool) {
        sendEvent(name: success ? "ScanQR SI right" : "ScanQR SI error")
    }

    func signInStatus(success: Bool) {
        sendEvent(name: success ? "SI success" : "SI error")
    }

    // MARK: - FTUE
    func ftueSubscribe(codes: [String]) {
        sendEvent(name: "Bounty subscribe", props: [
            "num": codes.count
        ])
    }
}

extension AnalyticsManger {
    private func sendEvent(name: String, props: Properties? = nil) {
        #if APPSTORE
            if let userID = Config.currentUser?.id {
                Amplitude.instance()?.setUserId(userID)
                AppsFlyerTracker.shared().customerUserID = userID
            }

            // Send to analytics
            if let props = props {
                Amplitude.instance()?.logEvent(name, withEventProperties: props)
            } else {
                Amplitude.instance()?.logEvent(name)
            }
            // Send to Firebase
            Analytics.logEvent(name, parameters: props)
            AppsFlyerTracker.shared().trackEvent(name, withValues: props)
        #endif
    }
}
