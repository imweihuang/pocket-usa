//
//  BookmarkViewController.swift
//  Pocket USA
//
//  Created by Wei Huang on 6/2/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
import DataKit

class BookmarkViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var bookmarkTabelView: UITableView!
    var bookmarks = NSMutableArray()
    let placeHolderImageView = UIImageView(frame: CGRect(x: 0, y: 200, width: 375, height: 467))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bookmarkTabelView.delegate = self
        bookmarkTabelView.dataSource = self
        bookmarkTabelView.separatorStyle = .none
        bookmarkTabelView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        placeHolderImageView.image = #imageLiteral(resourceName: "bookmarkPlaceholder")
        initGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bookmarks = AppGroupDefaultsManager.sharedInstance.currentList()
        bookmarkTabelView.reloadData()
        print("### current list - BookMarkViewController: \(bookmarks)")
        print("### current list count - BookMarkViewController: \(bookmarks.count)")
    }
    
    // Initialize gesture
    func initGesture() {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the  number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if bookmarks.count == 0 {
            view.addSubview(placeHolderImageView)
        } else {
            placeHolderImageView.removeFromSuperview()
        }
        return bookmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath) as! BookmarkTableViewCell
        // Configure cell
        let itemDict = bookmarks[indexPath.row] as! NSDictionary
        print("### bookmark type: \(itemDict["bookmarkType"] as! String)")
        if itemDict["bookmarkType"] as! String == "income" {
            let locationID = itemDict["locationID"] as! String
            cell.cardView.addSubview(IncomeCardView(locationID, bookmark: true))
        } else if itemDict["bookmarkType"] as! String == "age" {
            let locationID = itemDict["locationID"] as! String
            cell.cardView.addSubview(AgeCardView(locationID, bookmark: true))
        } else if itemDict["bookmarkType"] as! String == "property" {
            let locationID = itemDict["locationID"] as! String
            cell.cardView.addSubview(PropertyCardView(locationID, bookmark: true))
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
