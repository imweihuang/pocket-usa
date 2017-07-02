//
//  SearchTableCell.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/11/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
// Reusable cell in the search table
class SearchTableCell: UITableViewCell {
    
    
    @IBOutlet weak var searchTableCellText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
