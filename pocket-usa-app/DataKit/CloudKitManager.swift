//
//  CloudKitManager.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/1/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import Foundation
import CloudKit
import UserNotifications

var currentUserRecordIDName = ""

open class CloudKitManager {
    
    open static let sharedInstance = CloudKitManager()
    
    // MARK: Properties
    let container: CKContainer = CKContainer.default()
    let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
    var userRecordID: CKRecordID? // Current user
    
    // Keep it safe
    private init() {}
    open func getUserRecordId() {
        let container = CKContainer.default()
        container.fetchUserRecordID() {
            recordID, error in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                // We have access to the user's record
                print("fetched ID \(recordID?.recordName ?? "")")
                currentUserRecordIDName = (recordID?.recordName)!
            }
        }
    }
    
    // MARK: - Queries
    open func getRecordById(_ recordId: CKRecordID,
                            completion: @escaping (CKRecord?, NSError?) -> ()) {
        publicDB.fetch(withRecordID: recordId) { (record, error) in
            if let error = error {
                print("Error: \(String(describing: error.localizedDescription))")
                completion(nil, error as NSError?)
            }
            if let record = record {
                print(record.description)
                completion(record, nil)
            }
        }
        
    }
    
    // MARK: - Subscriptions
    open func registerSilentSubscriptionsForAdminNotificationsWithIdentifier(_ identifier: String) {
        
        let uuid: UUID = UIDevice().identifierForVendor!
        let identifier = "\(uuid)-admin"
        
        // Create the notification that will be delivered
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        
        let subscription = CKQuerySubscription(recordType: "AdminNotifications",
                                               predicate: NSPredicate(value: true),
                                               subscriptionID: identifier,
                                               options: [.firesOnRecordCreation])
        subscription.notificationInfo = notificationInfo
        CKContainer.default().publicCloudDatabase.save(subscription, completionHandler: ({returnRecord, error in
            if let err = error {
                print("### subscription failed \(err.localizedDescription)")
            } else {
                print("### subscription set up")
            }
        }))
    }
}
