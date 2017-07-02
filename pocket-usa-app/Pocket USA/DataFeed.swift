//
//  DataManager.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import Foundation
// Source feed in the JSON
public struct DataFeed: Decodable {
    
    public var dataFeed: [AnyObject]!
    
    public init?(json: JSON) {
        guard let dataFeed: [AnyObject] = "data" <~~ json else {
            return nil
        }
        
        self.dataFeed = dataFeed
    }
}
