//
//  DataManager.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//
//  - Attribution: Swift JSON Tutorial: Working with JSON > www.raywenderlich.com
//

import Foundation
import UIKit

protocol DataManagerDelegate: class {
    func showNetworkAlert(_ error: Error)
}

// Manage data and network request
public class DataManager {
    static var shared = DataManager()
    weak var alertDelegate: DataManagerDelegate?
    
    public init () {
        
    }
    
    // Get medium data
    func getMediumDataWithSuccess(_ locationID: String, _ parentLocationIds: [String], success: @escaping ((_ inData: Data) -> Void)) {
        var mediumDataURL = "https://api.datausa.io/api/?sort=desc&show=geo&required=income%2Cmedian_property_value%2Cage&sumlevel=all&year=latest&geo="
        var countyCount = 0
        for location in parentLocationIds {
            // Allow only nation, state, county and city
            let index = location.index(location.startIndex, offsetBy: 3)
            let prefix = location.substring(to: index)
            print("### Prefix: \(prefix), for locationID \(location)")
            if (prefix == "010" || prefix == "040" || prefix == "050" || prefix == "160") {
                // Alow only two counties
                if (prefix == "050" && countyCount >= 2) {
                    // Do nonting
                } else {
                    // Append location for search
                    mediumDataURL += "\(location)%2C"
                    print("### Add Location: \(location)")
                    if (prefix == "050") {
                        countyCount += 1
                    }
                }
            }
        }
        mediumDataURL += locationID
        print("### URL-mediumHouseholdIncomeURL: \(mediumDataURL)")
        loadDataFromURL(url: URL(string: mediumDataURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Get location ID from location name
    func getLocationIdWithSuccess(_ location: String, success: @escaping ((_ inData: Data) -> Void)) {
        let locationIdURL = "https://api.datausa.io/attrs/search/?q=\(location)&kind=geo"
        print("### URL-locationIdURL: \(locationIdURL)")
        loadDataFromURL(url: URL(string: locationIdURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Get partent/related location IDs from for a location id
    func getParentLocationIDsWithSuccess(_ locationID: String, success: @escaping ((_ inData: Data) -> Void)) {
        let parentLocationIDsURL = "https://api.datausa.io/attrs/geo/\(locationID)/parents/"
        print("### URL-parentLocationIDsURL: \(parentLocationIDsURL)")
        loadDataFromURL(url: URL(string: parentLocationIDsURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Get search results from search term
    func getSearchResultsWithSuccess(_ searchTerm: String, success: @escaping ((_ inData: Data) -> Void)) {
        let searchResultsURL = "https://api.datausa.io/attrs/search/?q=\(searchTerm)&kind=geo"
        print("### URL-searchResultsURL: \(searchResultsURL)")
        loadDataFromURL(url: URL(string: searchResultsURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Get location summary from location id
    func getLocatoinSummaryWithSuccess(_ locationId: String, success: @escaping ((_ inData: Data) -> Void)) {
        let locationSummaryURL = "https://api.datausa.io/api/?sort=desc&force=acs.yg&show=geo&sumlevel=all&year=latest&geo=\(locationId)"
        print("### URL-locationSummaryURL: \(locationSummaryURL)")
        loadDataFromURL(url: URL(string: locationSummaryURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Get location name from location id
    func getLocationNameWithSuccess(_ locationId: String, success: @escaping ((_ inData: Data) -> Void)) {
        let locationNameURL = "https://api.datausa.io/attrs/geo/\(locationId)/"
        print("### URL-locationNameURL: \(locationNameURL)")
        loadDataFromURL(url: URL(string: locationNameURL)!) { (data, error) -> Void in
            if let data = data {
                success(data)
            }
        }
    }
    
    // Load data from URL
    func loadDataFromURL(url: URL, completion: @escaping (_ data: Data?, _ error: Error?) -> Void) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let loadDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    self.alertDelegate?.showNetworkAlert(error) // Network Alert
                    completion(nil, error)
                } else if let response = response as? HTTPURLResponse {
                    if response.statusCode != 200 {
                        let statusError = NSError(domain: "api.datausa.io",
                                                  code: response.statusCode,
                                                  userInfo: [NSLocalizedDescriptionKey: "HTTP status code has unexpected value."])
                        self.alertDelegate?.showNetworkAlert(statusError) // Network Alert
                        completion(nil, statusError)
                    } else {
                        completion(data, nil)
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                print("### Load Data Onilne Done")
            }
            loadDataTask.resume()
        }
    }
}
