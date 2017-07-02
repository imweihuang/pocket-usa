//
//  ViewController.swift
//  Pocket USA Admin
//
//  Created by Wei Huang on 6/3/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppearance()
    }
    
    // MARK: IBAction
    @IBAction func sendButtonAction(_ sender: Any) {
        if isReady() {
            sendButton.isEnabled = false
            sendButton.setTitle("SENDING...", for: .normal)
            CloudKitManager.sharedInstance.addAdminNotificationToCloud(title: titleTextField.text!, body: bodyTextField.text!) {
                DispatchQueue.main.async {
                    self.showAlert(withTitle: "Awesom", message: "Notification Sent")
                    self.sendButton.isEnabled = true
                    self.sendButton.setTitle("SEND", for: .normal)
                    self.titleTextField.text = ""
                    self.bodyTextField.text = ""
                }
            }
        }
    }
    
    
    // MARK: - UI
    func initAppearance() {
        sendButton.clipsToBounds = true
        sendButton.layer.cornerRadius = 4
        sendButton.layer.borderWidth = 0.5
        sendButton.layer.borderColor = UIColor.lightGray.cgColor
        titleTextField.delegate = self
        bodyTextField.delegate = self
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(string == "\n") {
            textField.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - Others
    func isReady() -> Bool {
        if titleTextField.text != nil && bodyTextField.text != nil {
            return true
        } else {
            showAlert(withTitle: "Not Ready Yet", message: "Please provide required conents")
            return false
        }
    }
}

// MARK: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

