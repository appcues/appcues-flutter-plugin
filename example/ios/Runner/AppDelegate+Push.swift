//
//  AppDelegate+Push.swift
//  Runner
//
//  Created by Matt on 2025-05-01.
//

// Disabled in favor of automatic configuration

/*
import Foundation
import UserNotifications
import appcues_flutter

extension AppDelegate {
    /// Call from `UIApplicationDelegate.application(_:didFinishLaunchingWithOptions:)`
    func setupPush(application: UIApplication) {
        // 1: Register to get a device token
        application.registerForRemoteNotifications()

        UNUserNotificationCenter.current().delegate = self
    }

    // 2: Pass device token to Appcues
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
      AppcuesFlutterPlugin.setPushToken(deviceToken)
    }

    // 3: Pass the user's response to a delivered notification to Appcues
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if AppcuesFlutterPlugin.didReceiveNotification(response: response, completionHandler: completionHandler) {
            return
        }

        super.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }

    // 4: Configure handling for notifications that arrive while the app is in the foreground
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .list])
        } else {
            completionHandler(.alert)
        }
    }
}
*/
