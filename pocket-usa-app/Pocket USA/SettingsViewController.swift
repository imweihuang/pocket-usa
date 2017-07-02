//
//  SettingsViewController.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
import ChameleonFramework
import DataKit

class SettingsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var bookmarkBulletLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initGesture()
        initBookmarkSec()
    }
    
    // Initialize gesture
    func initGesture() {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // Initialize bookmark button
    func initBookmarkSec() {
        bookmarkBulletLabel.text = "\u{25A0}"
        bookmarkBulletLabel.textColor = RandomFlatColor()
        if AppGroupDefaultsManager.sharedInstance.currentList().count == 0 {
            clearButton.backgroundColor = .gray
            clearButton.isEnabled = false
        } else {
            clearButton.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
            clearButton.isEnabled = true
        }
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.setTitleColor(.white, for: .highlighted)
        clearButton.clipsToBounds = true
        clearButton.layer.cornerRadius = 4
    }
    
    // Clear button action
    @IBAction func clearButtonAction(_ sender: Any) {
        AppGroupDefaultsManager.sharedInstance.reset()
        clearButton.backgroundColor = .gray
        clearButton.isEnabled = false
    }
}
