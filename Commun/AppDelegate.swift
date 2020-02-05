//
//  AppDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
//  https://console.firebase.google.com/project/golos-5b0d5/notification/compose?campaignId=9093831260433778480&dupe=true
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import CyberSwift
@_exported import CyberSwift
import RxSwift
import RxCocoa
import SDURLCache
import SDWebImageWebPCoder
import ListPlaceholder

let isDebugMode: Bool = true
let smsCodeDebug: UInt64 = isDebugMode ? 9999 : 0
let gcmMessageIDKey = "gcm.message_id"
let firstInstallAppKey = "com.commun.ios.firstInstallAppKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    
    static var reloadSubject = PublishSubject<Bool>()
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationRelay = BehaviorRelay<ResponseAPIGetNotificationItem>(value: ResponseAPIGetNotificationItem.empty)
    
    let deepLinkPath = BehaviorRelay<[String]>(value: [])
    
    private var bag = DisposeBag()

    private func configureFirebase() {
        #if APPSTORE
            let fileName = "GoogleService-Info-Prod"
        #else
            let fileName = "GoogleService-Info-Dev"
        #endif
        let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
            else { assert(false, "Couldn't load config file"); return }
        FirebaseApp.configure(options: fileopts)
    }

    // MARK: - Class Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // first fun app
        if !UserDefaults.standard.bool(forKey: firstInstallAppKey) {
            // Analytics
            AnalyticsManger.shared.launchFirstTime()
            
            UserDefaults.standard.set(true, forKey: firstInstallAppKey)
        }
        
        // create deviceId
        if KeychainManager.currentDeviceId == nil {
            let id = UUID().uuidString + "." + "\(Date().timeIntervalSince1970)"
            do {
                try KeychainManager.save([Config.currentDeviceIdKey: id])
            } catch {
                Logger.log(message: error.localizedDescription, event: .debug)
            }
        }

        AnalyticsManger.shared.sessionStart()
        // Use Firebase library to configure APIs
        configureFirebase()
        
        // ask for permission for sending notifications
        configureNotifications()

        // Config Fabric
        Fabric.with([Crashlytics.self])

        // global tintColor
        window?.tintColor = .appMainColor
        // Logger
//        Logger.showEvents = [.debug]

        // support webp image
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        // Sync iCloud key-value store
        NSUbiquitousKeyValueStore.default.synchronize()
        
        // Hide constraint warning
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        
        // handle connected
        SocketManager.shared.connected
            .filter {$0}
            .debounce(0.3, scheduler: MainScheduler.instance)
            .take(1)
            .asSingle()
            .timeout(5, scheduler: MainScheduler.instance)
            .subscribe(onSuccess: { (_) in
                AppDelegate.reloadSubject.onNext(false)
                self.window?.makeKeyAndVisible()
            }, onError: {_ in
                if let vc = self.window?.rootViewController as? SplashViewController {
                    vc.showErrorScreen()
                }
            })
            .disposed(by: bag)
        
        // Reload app
        AppDelegate.reloadSubject
            .subscribe(onNext: {force in
                self.navigateWithRegistrationStep(force: force)
            })
            .disposed(by: bag)
        
        // cache
        if let urlCache = SDURLCache(memoryCapacity: 0, diskCapacity: 2*1024*1024*1024, diskPath: SDURLCache.defaultCachePath(), enableForIOS5AndUp: true) {
            URLCache.shared = urlCache
        }
        
        // badge
        SocketManager.shared.unseenNotificationsRelay
            .subscribe(onNext: { (count) in
                UIApplication.shared.applicationIconBadgeNumber = Int(count)
            })
            .disposed(by: bag)
        
        return true
    }
    
    func navigateWithRegistrationStep(force: Bool = false) {
        let completion = {
            let step = KeychainManager.currentUser()?.registrationStep ?? .firstStep
            // Registered user
            if step == .registered || step == .relogined {
                // If first setting is uncompleted
                let settingStep = KeychainManager.currentUser()?.settingStep ?? .backUpICloud
                if settingStep != .completed {
                    if !force,
                        let nc = self.window?.rootViewController as? UINavigationController,
                        (nc.viewControllers.first is BackUpKeysVC || nc.viewControllers.first is BoardingSetPasscodeVC)
                    {
                        return
                    }
                    
                    let vc: UIViewController
                    
                    if KeychainManager.currentUser()?.registrationStep == .relogined {
                        vc = BoardingSetPasscodeVC()
                    } else {
                        vc = BackUpKeysVC()
                    }
                    
                    let nc = UINavigationController(rootViewController: vc)
                    
                    self.changeRootVC(nc)
                    return
                }
                
                // if all set
                RestAPIManager.instance.authorize()
                    .subscribe(onSuccess: { (_) in
                        // Retrieve favourites
                        FavouritesList.shared.retrieve()
                        
                        // show feed
                        if !force && (self.window?.rootViewController is TabBarVC) {return}
                        self.changeRootVC(controllerContainer.resolve(TabBarVC.self)!)
                        
                        // set info
                        self.deviceSetInfo()
                    }, onError: { (error) in
                        if let error = error as? ErrorAPI {
                            switch error.caseInfo.message {
                            case "Cannot get such account from BC",
                                 _ where error.caseInfo.message.hasPrefix("Can't resolve name"):
                                do {
                                    try KeychainManager.deleteUser()
                                    AppDelegate.reloadSubject.onNext(true)
                                } catch {
                                    print("Could not delete user from key chain")
                                }
                                return
                            default:
                                break
                            }
                        }
                        if let splashVC = self.window?.rootViewController as? SplashViewController {
                            splashVC.showErrorScreen()
                        }
                        
                    })
                    .disposed(by: self.bag)
                
                // New user
            } else {
                if !force,
                    let nc = self.window?.rootViewController as? UINavigationController,
                    nc.viewControllers.first is WelcomeVC {
                    return
                }
                
                let welcomeVC = controllerContainer.resolve(WelcomeVC.self)
                let welcomeNav = UINavigationController(rootViewController: welcomeVC!)
                self.changeRootVC(welcomeNav)
                
                let navigationBarAppearace = UINavigationBar.appearance()
                navigationBarAppearace.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
                navigationBarAppearace.largeTitleTextAttributes =   [
                                                                        NSAttributedString.Key.foregroundColor: UIColor.black,
                                                                        NSAttributedString.Key.font: UIFont(name: "SFProDisplay-Bold",
                                                                                                                           size: 30.0 * Config.widthRatio)!
                ]
            }
        }
        
        if force, let vc = window?.rootViewController, !(vc is SplashViewController) {
            // Closing animation
            let vc = controllerContainer.resolve(SplashViewController.self)!
            self.window?.rootViewController = vc
            completion()
        } else {
            completion()
        }
    }
    
    func changeRootVC(_ rootVC: UIViewController) {
        if let currentVC = window?.rootViewController as? SplashViewController {
            currentVC.animateSplash {
                self.window?.rootViewController = rootVC
            }
        } else {
            self.window?.rootViewController = rootVC
        }

        getConfig { (error) in
            // Animation
            rootVC.view.alpha = 0
            UIView.animate(withDuration: 0.5, animations: {
                rootVC.view.alpha = 1
                if let error = error {
                    if error.toErrorAPI().caseInfo.message == "Need update application version" {
                        rootVC.view.showForceUpdate()
                        return
                    }

                    print("getConfig = \(error)")
                }
            })
        }
    }
    
    func getConfig(completion: @escaping ((Error?) -> Void)) {
        RestAPIManager.instance.getConfig()
            .subscribe(onSuccess: { _ in
                completion(nil)
            }) { (error) in
                completion(error)
            }
            .disposed(by: bag)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AnalyticsManger.shared.backgroundApp()
        SocketManager.shared.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AnalyticsManger.shared.foregroundApp()
        SocketManager.shared.connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.appGroups.removeObject(forKey: appShareExtensionKey)
        SocketManager.shared.disconnect()
        self.saveContext()
    }
    
    
    // MARK: - Custom Functions
    private func configureNotifications() {
        // Set delegate for Messaging
        Messaging.messaging().delegate = self
        
        // Configure notificationCenter
        self.notificationCenter.delegate = self
        
        self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge],
                                                     completionHandler: { (granted, _) in
                                                        Logger.log(message: "Permission granted: \(granted)", event: .debug)
                                                        guard granted else { return }
                                                        self.getNotificationSettings()
        })
        
        // Register for remote notification
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func getNotificationSettings() {
        self.notificationCenter.getNotificationSettings(completionHandler: { (settings) in
            Logger.log(message: "Notification settings: \(settings)", event: .debug)
        })
    }
    
    private func deviceSetInfo() {
        // set info
        let key = "AppDelegate.setInfo"
        if !UserDefaults.standard.bool(forKey: key) {
            let offset = -TimeZone.current.secondsFromGMT() / 60
            RestAPIManager.instance.deviceSetInfo(timeZoneOffset: offset)
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: key)
                })
                .disposed(by: bag)
        }
        
        // fcm token
        if !UserDefaults.standard.bool(forKey: Config.currentDeviceDidSendFCMToken)
        {
            UserDefaults.standard.rx.observe(String.self, Config.currentDeviceFcmTokenKey)
                .filter {$0 != nil}
                .map {$0!}
                .take(1)
                .asSingle()
                .flatMap {RestAPIManager.instance.deviceSetFcmToken($0)}
                .subscribe(onSuccess: { (_) in
                    UserDefaults.standard.set(true, forKey: Config.currentDeviceDidSendFCMToken)
                })
                .disposed(by: bag)
        }
    }

    private func scheduleLocalNotification(userInfo: [AnyHashable: Any]) {
        let notificationContent                 =   UNMutableNotificationContent()
        let categoryIdentifier                  =   userInfo["category"] as? String ?? "Commun"
        
        notificationContent.title               =   userInfo["title"] as? String ?? "Commun"
        notificationContent.body                =   userInfo["body"] as? String ?? "Commun"
        notificationContent.sound               =   userInfo["sound"] as? UNNotificationSound ?? UNNotificationSound.default
        notificationContent.badge               =   userInfo["badge"] as? NSNumber ?? 1
        notificationContent.categoryIdentifier  =   categoryIdentifier
        
        let trigger         =   UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier      =   "Commun Local Notification"
        let request         =   UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
        
        self.notificationCenter.add(request) { (error) in
            if let error = error {
                Logger.log(message: "Error \(error.localizedDescription)", event: .error)
            }
        }
        
        let snoozeAction    =   UNNotificationAction(identifier: "ActionSnooze", title: "Snooze".localized(), options: [])
        let deleteAction    =   UNNotificationAction(identifier: "ActionDelete", title: "delete".localized().uppercaseFirst, options: [.destructive])
        
        let category        =   UNNotificationCategory(identifier: categoryIdentifier,
                                                       actions: [snoozeAction, deleteAction],
                                                       intentIdentifiers: [],
                                                       options: [])
        
        self.notificationCenter.setNotificationCategories([category])
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Commun")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Firebase Cloud Messaging (FCM)
extension AppDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:  @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)

        completionHandler(UIBackgroundFetchResult.newData)
    }
   
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.log(message: "Unable to register for remote notifications: \(error.localizedDescription)", event: .error)
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.log(message: "APNs token retrieved: \(deviceToken)", event: .severe)
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive push-message when App is active/in background
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler:    @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display Local Notification
        let notificationContent = notification.request.content
        
        // Print full message.
        Logger.log(message: "UINotificationContent: \(notificationContent)", event: .debug)

        completionHandler([.alert, .sound])
    }
    
    // Tap on push message
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:    @escaping () -> Void) {
        let notificationContent = response.notification.request.content
        
        if response.notification.request.identifier == "Local Notification" {
            Logger.log(message: "Handling notifications with the Local Notification Identifier", event: .debug)
        }

        // Print full message.
        Logger.log(message: "UINotificationContent: \(notificationContent)", event: .debug)
        
        // decode notification
        if let string = notificationContent.userInfo["notification"] as? String,
            let data = string.data(using: .utf8)
        {
            do {
                let notification = try JSONDecoder().decode(ResponseAPIGetNotificationItem.self, from: data)
                notificationRelay.accept(notification)
            } catch {
                Logger.log(message: "Receiving notification error: \(error)", event: .error)
            }
        }

        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String) {
        Logger.log(message: "FCM registration token: \(fcmToken)", event: .severe)
        
        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        UserDefaults.standard.set(fcmToken, forKey: Config.currentDeviceFcmTokenKey)

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Logger.log(message: "Received data message: \(remoteMessage.appData)", event: .severe)
    }
}

// MARK: - Deeplink
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let path = Array(url.path.components(separatedBy: "/").dropFirst())
            if path.count == 1 || path.count == 3 {
                deepLinkPath.accept(path)
                return true
            }
        }

        return false
    }
}

// MARK: - Share Extension pass data
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        switch url.description {
        case "commun://createPost":
            if let tabBar = self.window?.rootViewController as? TabBarVC {
                if let presentedVC = tabBar.presentedViewController as? BasicEditorVC {
                    presentedVC.loadShareExtensionData()
                } else {
                    tabBar.buttonAddTapped()
                }
            }
       
        default:
            return false
        }
        
        return true
    }
}
