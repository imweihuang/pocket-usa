//
//  DataManager.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import Foundation
// Source feed in the JSON
public struct SourceFeed: Decodable {
    
    public let orgName: String?
    
    public init?(json: JSON) {
        guard let sourceFeed: JSON = "source" <~~ json,
            let orgName: String = "org" <~~ sourceFeed else {
                return nil
        }
        self.orgName = orgName
    }
}
