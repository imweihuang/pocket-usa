//
//  AppGroupManager.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/1/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//


import Foundation
import UserNotifications

let sharedAppGroup: String = "group.uchicago.pocket.usa" // App group identifier
let favoritesKey: String = "Favorites" // Defaults storage key

// MARK: - App group manager protocol
protocol AppGroupManager {
    func add(object anObject: NSObject)
    func reset()
    func remove(_ bookmarkID: String)
    func alreadyAdded(_ bookmarkID: String) -> Bool
    func currentList() -> NSMutableArray
}

// MARK: - App Group Defaults Manager
public class AppGroupDefaultsManager: AppGroupManager {
    
    public static let sharedInstance = AppGroupDefaultsManager()
    let sharedDefaults: UserDefaults?
    var favorites: NSMutableArray?
    
    init() {
        sharedDefaults = UserDefaults(suiteName: sharedAppGroup)
        // print(sharedDefaults?.dictionaryRepresentation() as Any)
    }
    
    // For favoriate locations
    public func add(object anObject: NSObject) {
        let current: NSMutableArray = currentList()
        //        current.add(anObject)
        current.insert(anObject, at: 0)
        sharedDefaults?.set(current, forKey: favoritesKey)
        sharedDefaults?.synchronize()
    }
    public func remove(_ bookmarkID: String) {
        let current: NSMutableArray = currentList()
        for item in current {
            let itemDict = item as! NSDictionary
            if bookmarkID == itemDict["bookmarkID"] as! String {
                current.remove(item)
            }
        }
        sharedDefaults?.set(current, forKey: favoritesKey)
        sharedDefaults?.synchronize()
    }
    public func alreadyAdded(_ bookmarkID: String) -> Bool {
        let sharedItems: NSMutableArray = currentList()
        for item in sharedItems {
            let itemDict = item as! NSDictionary
            if bookmarkID == itemDict["bookmarkID"] as! String {
                return true
            }
        }
        return false
    }
    public func currentList() -> NSMutableArray {
        var current: NSMutableArray = []
        if let tempNames: NSArray = sharedDefaults?.array(forKey: favoritesKey) as NSArray? {
            current = tempNames.mutableCopy() as! NSMutableArray
        }
        return current
    }
    public func reset() {
        sharedDefaults?.set(NSMutableArray(), forKey: favoritesKey)
        sharedDefaults?.synchronize()
    }
}
