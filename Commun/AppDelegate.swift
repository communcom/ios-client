//
//  AppDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Maxim Prigozhenkov. All rights reserved.
//
//  https://console.firebase.google.com/u/0/project/io-commun-eos-ios/notification/compose?campaignId=4674196189067671007&dupe=true
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import Firebase
import UserNotifications
import CyberSwift
@_exported import CyberSwift

let isDebugMode: Bool = true
let smsCodeDebug: UInt64 = isDebugMode ? 9999 : 0
let gcmMessageIDKey = "gcm.message_id"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?


    // MARK: - Class Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Run WebSocket
        WebSocketManager.instance.connect()
        
        _ = WebSocketManager.instance.authorized
            .skip(1)
            .subscribe(onNext: {success in
                Logger.log(message: "Sign: \n\t\(success)", event: .debug)

                // Lenta
                if success,
                    UserDefaults.standard.value(forKey: Config.isCurrentUserLoggedKey) as? Bool == true {
                    self.window?.rootViewController = controllerContainer.resolve(TabBarVC.self)
                }

                // Sign In/Up
                else {
                    self.showLogin()
                }
        
                self.window?.makeKeyAndVisible()
                application.applicationIconBadgeNumber = 0
            })
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Register for remote notifications
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func showLogin() {
        let welcomeVC = controllerContainer.resolve(WelcomeScreenVC.self)
        let welcomeNav = UINavigationController(rootViewController: welcomeVC!)
        self.window?.rootViewController = welcomeNav

        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = #colorLiteral(red: 0.4156862745, green: 0.5019607843, blue: 0.9607843137, alpha: 1)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pau ]]]]]]]]se the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//        NetworkService.shared.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
//        NetworkService.shared.connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
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
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
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
    func application(_ application:                             UIApplication,
                     didReceiveRemoteNotification userInfo:     [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)
    }
    
    func application(_ application:                             UIApplication,
                     didReceiveRemoteNotification userInfo:     [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:  @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)

        completionHandler(UIBackgroundFetchResult.newData)
    }
   
    func application(_ application:                                             UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error:    Error) {
        Logger.log(message: "Unable to register for remote notifications: \(error.localizedDescription)", event: .error)
    }
    
    func application(_ application:                                                 UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken:  Data) {
        Logger.log(message: "APNs token retrieved: \(deviceToken)", event: .severe)
        
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
}


// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center:                                   UNUserNotificationCenter,
                                willPresent notification:                   UNNotification,
                                withCompletionHandler completionHandler:    @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center:                                   UNUserNotificationCenter,
                                didReceive response:                        UNNotificationResponse,
                                withCompletionHandler completionHandler:    @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }
        
        // Print full message.
        print(userInfo)

        completionHandler()
    }
}


// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging:                             Messaging,
                   didReceiveRegistrationToken fcmToken:    String) {
        Logger.log(message: "FCM registration token: \(fcmToken)", event: .severe)
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Logger.log(message: "Received data message: \(remoteMessage.appData)", event: .severe)
    }
}
