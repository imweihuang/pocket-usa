//
//  RearViewController.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/1/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
import ChameleonFramework

class RearViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var comparisonLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!

    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("### Rear view did load")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("### Rear view will appear")
        initLabels()
    }
    
    func initLabels() {
        homeLabel.text = "\u{25A0}"
        homeLabel.textColor = .randomFlat
        comparisonLabel.text = "\u{25A0}"
        comparisonLabel.textColor = .randomFlat
        historyLabel.text = "\u{25A0}"
        historyLabel.textColor = .randomFlat
    }
}
