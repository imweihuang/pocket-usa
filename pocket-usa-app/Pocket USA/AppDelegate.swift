//
//  AppDelegate.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/10/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
import DataKit
import CloudKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Set the notification delegate
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else {
                application.registerForRemoteNotifications()
            }
        }
        UNUserNotificationCenter.current().delegate = self
        // Register subscriptions
        CloudKitManager.sharedInstance.registerSilentSubscriptionsForAdminNotificationsWithIdentifier("id9")
        // Parse the launch notification so that we can get the payload
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String: AnyObject]
            print("APS: \(aps)")
        }
        return true
    }
    
    // Show notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    /// Called for push notifications
    /// In this case, we are getting the changed record from cloudkit and then creating a new notification
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let aps = userInfo["aps"] as! [String: AnyObject]
        print("APS: \(aps)")
        
        let contentAvailable = aps["content-available"] as! Int
        if contentAvailable == 1 {
            
            // Pull data
            let cloudKitInfo = userInfo["ck"] as! [String: AnyObject]
            
            // Get the record id
            let rid = cloudKitInfo["qry"]?["rid"] as! String
            let ckrid = CKRecordID(recordName: rid)
            
            // Get the cloudkit record (by id)
            CloudKitManager.sharedInstance.getRecordById(ckrid, completion: { (record, error) in
                
                print("### Record from silent notification: \(String(describing: record))")
                
                let content = UNMutableNotificationContent()
                content.sound = UNNotificationSound.default()
                if record?.recordType == "AdminNotifications" {
                    // Create notification content
                    content.title = record?["title"]! as! String
                    content.body = record?["body"]! as! String
                }
                
                // Set up trigger
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,repeats: false)
                
                // Create the notification request
                let center = UNUserNotificationCenter.current()
                let identifier = "UYLLocalNotification"
                let request = UNNotificationRequest(identifier: identifier,
                                                    content: content, trigger: trigger)
                center.add(request, withCompletionHandler: { (error) in
                    if let error = error {
                        print("### Error: \(error.localizedDescription)")
                    }
                })
                completionHandler(.newData)
            })
        } else {
            completionHandler(.noData)
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

