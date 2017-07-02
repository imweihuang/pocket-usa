//
//  WebViewController.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    var location = "Chicago"

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        let imageSearchTerm = location.replacingOccurrences(of: " ", with: "+")
        webView.loadRequest(NSURLRequest(url: NSURL(string: "https://www.google.com/search?q=\(imageSearchTerm)&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjEieXozKDUAhWm1IMKHcqCDfgQ_AUIDCgD&biw=1680&bih=950")! as URL) as URLRequest)
    }

        // Do any additional setup after loading the view.

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
