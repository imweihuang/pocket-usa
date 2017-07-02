//
//  CloudKitManager.swift
//  Pocket USA Admin
//
//  Created by Wei Huang on 6/3/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//


import Foundation
import CloudKit

open class CloudKitManager {
    
    open static let sharedInstance = CloudKitManager()
    
    // MARK: Properties
    let container: CKContainer = CKContainer.init(identifier: "iCloud.uchicago.pocket.usa")
    let publicDB: CKDatabase = CKContainer.init(identifier: "iCloud.uchicago.pocket.usa").publicCloudDatabase
    let privateDB: CKDatabase = CKContainer.init(identifier: "iCloud.uchicago.pocket.usa").privateCloudDatabase
    
    // Keep it safe
    private init() {}
    
    func addAdminNotificationToCloud(title: String, body: String, completion: @escaping () -> Void) {
        let adminNotificationRecordID = CKRecordID(recordName: UUID().uuidString)
        let record = CKRecord(recordType: "AdminNotifications", recordID: adminNotificationRecordID)
        //        record.setValue(joke.userRecordIDName, forKey: "userRecordID")
        record["title"] = title as CKRecordValue
        record["body"] = body as CKRecordValue
        publicDB.save(record) { (record, error) in
            if let error = error {
                print("### Error: \(error.localizedDescription)")
                return
            }
            print("### Saved record: \(record.debugDescription)")
            completion()
        }
    }
}

