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

    enum RegType: String {
        case google
        case apple
        case facebook
        case email
        case phone
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
    func signUpButtonPressed() {
        sendEvent(name: "Click Get started(slide 3)")
    }

    // MARK: - Sign Up

    // MARK: Sign Up Method
    func registrationOpenScreen(_ type: RegType) {
        sendEvent(name: "Click Sign up \(type.rawValue.uppercaseFirst)")
    }

    func goToSignIn() {
        sendEvent(name: "Click Go to Sign in")
    }

    func openRegistrationSelection() {
        sendEvent(name: "Open screen Sign up")
    }

    // MARK: Sign Up With Phone
    func countrySelected(phoneCode: String, available: Bool) {
        sendEvent(name: "Country selected", props: [
            "phoneCode": phoneCode,
            "available": available
        ])
    }

    func phoneNumberEntered() {
        sendEvent(name: "Phone number entered")
    }

    func smsCodeEntered(answer: Bool) {
        sendEvent(name: "Sms code entered", props: [
            "answer": answer
        ])
    }

    func openSmsCodeView() {
        sendEvent(name: "Open sms code")
    }

    func resendSmsCode() {
        sendEvent(name: "Resend sms code")
    }

    // MARK: Sign Up With Email
    func emailEntered() {
        sendEvent(name: "Email entered")
    }

    func emailCodeEntered(answer: Bool) {
        sendEvent(name: "Email code entered", props: [
            "answer": answer
        ])
    }

    func openEmailCodeView() {
        sendEvent(name: "Open email code")
    }

    func resendEmailCode() {
        sendEvent(name: "Resend email code")
    }

    // MARK: Username
    func userNameEntered(state: String) {
        sendEvent(name: "Username entered", props: [
            "available": state
        ])
    }

    func openScreenUsername() {
        sendEvent(name: "Open screen Username")
    }

    // MARK: Enter password
    func openEnterPassword() {
        sendEvent(name: "Open screen enter password")
    }

    func passwordEntered(available: Bool) {
        sendEvent(name: "Password entered", props: [
            "available": available
        ])
    }

    func useMasterPassword() {
        sendEvent(name: "Сlick use master password (enter password)")
    }

    // MARK: Confirm password
    func openReEnterPassword() {
        sendEvent(name: "Open screen confirm password")
    }

    func passwordConfirmed(available: Bool) {
        sendEvent(name: "Password confirmed", props: [
            "available": available
        ])
    }

    func passwordCreated() {
        sendEvent(name: "Сlick next (confirm password)")
    }

    // MARK: - Attention
    func clickBackupAttention() {
        sendEvent(name: "Click Backup (Attention)")
    }

    func openScreenAttention() {
        sendEvent(name: "Open screen Attention")
    }

    func saveItMassterPassword() {
        sendEvent(name: "Click continue (Attention)")
    }

    // MARK: Attention Master Password
    func openScreenAttentionMasterPassword() {
        sendEvent(name: "Open screen Attention(Master Password)")
    }

    func clickBackMasterPassword() {
        sendEvent(name: "Click Back(Master)")
    }

    func clickContinueMasterPassword() {
        sendEvent(name: "Click Continue(Master)")
    }

    // MARK: Master Password
    func openMasterPasswordGenerated() {
        sendEvent(name: "Open screen Master password generated")
    }

    func passwordCopy() {
        sendEvent(name: "Click Copy(Master)")
    }

    func clickBackupMasterPassword() {
        sendEvent(name: "Click Backup(Master)")
    }

    func clickISaveItMasterPassword() {
        sendEvent(name: "Click I save it(Master)")
    }

    // MARK: - Total
    func successfulRegistration() {
        sendEvent(name: "Successful registration")
    }

    // MARK: - Sign In
    func openSignInScreen() {
        sendEvent(name: "Open Sign In Screen")
    }

    // MARK: - Onboarding
    func ftueSubscribe(codes: [String]) {
        sendEvent(name: "Bounty subscribe", props: [
            "num": codes.count
        ])
    }

    func clickDoneONB() {
        sendEvent(name: "Click Done ONB")
    }

    func scanQRStatus(success: Bool) {
        sendEvent(name: "ScanQR SI", props: [
            "available": success
        ])
    }

    func signInStatus(success: Bool) {
        sendEvent(name: success ? "SI success" : "SI error")
    }

    func activateFaceID(_ activate: Bool) {
        sendEvent(name: "FaceID/TouchID activated", props: ["answer": activate])
    }

    // MARK: - Dank
    func clickGetDankMeme() {
        sendEvent(name: "Click Get Dank Meme")
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

        print("AnalyticsManger.sendEvent\nname: \(name)\nprops: \(props ?? [:])")
    }
}
