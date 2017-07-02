//
//  ViewController.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/10/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//
// - Attribution: UISearchBar customization - Customise UISearchBar in Swift @ iosdevcenters.blogspot.com
// - Attribution: Delay execution - How To Create an Uber Splash Screen @ www.raywenderlich.com
import UIKit
import ChameleonFramework

var splashScreen = true

// Main view controller
class ViewController: UIViewController, UITableViewDataSource, UIScrollViewDelegate, UITableViewDelegate, UISearchBarDelegate {
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var populationLabel: UILabel!
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var cardtScrollView: UIScrollView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    @IBOutlet weak var searchDisplayButton: UIButton!
    @IBOutlet weak var networkOopusView: UIView!
    @IBOutlet weak var mapButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    var incomeCardView: UIView!
    var ageCardView: UIView!
    var propertyCardView: UIView!
    
    let sharedDM = DataManager()
    
    var searchActive = false
    var searchTerm = ""
    var searchResults = [[String]]()
    
    var location = "United States"
    var population: Double!
    var income: Double!
    var age: Double!
    var locationID = "01000US" {
        didSet {
            initLabels()
            initCardViews()
        }
    }
    
    // Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        sharedDM.alertDelegate = self
        showSplashScreen()
        initApprerance()
        initGesture()
        initSearchView()
        initCardScrollView()
        initCardViews()
        initSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // Initialize appreance
    func initApprerance() {
        //        self.navigationController?.setNavigationBarHidden(true, animated: animated) // Hide navigation bar
        
        // Map button appearance
        mapButton.setTitle("MAP", for: .normal)
        mapButton.setTitleColor(.darkGray, for: .normal)
        mapButton.setBackgroundImage(#imageLiteral(resourceName: "MapButton").withRenderingMode(.alwaysOriginal), for: .normal)
        mapButton.setBackgroundImage(#imageLiteral(resourceName: "MapButton").withRenderingMode(.alwaysOriginal), for: .highlighted)
        mapButton.clipsToBounds = true
        mapButton.layer.cornerRadius = 4
        
        // Image button appreaance
        imageButton.setTitle("GLANCE", for: .normal)
        imageButton.setTitleColor(.darkGray, for: .normal)
        imageButton.setBackgroundImage(#imageLiteral(resourceName: "ImageButton").withRenderingMode(.alwaysOriginal), for: .normal)
        imageButton.setBackgroundImage(#imageLiteral(resourceName: "ImageButton").withRenderingMode(.alwaysOriginal), for: .highlighted)
        imageButton.clipsToBounds = true
        imageButton.layer.cornerRadius = 4
    }
    
    // Initialize gesture
    func initGesture() {
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    }
    
    // Initialize
    func initLabels() {
        // Get location summary
        getLocationSummary(self.locationID) {
            () -> Void in
            self.locationLabel.text = self.location.uppercased()
            self.initPopulationLabel()
            self.initIncomeLabel()
            self.initAgeLabel()
        }
    }
    
    // Init population label
    func initPopulationLabel() {
        guard let pop = self.population else
        {
            print("### ERROR: population empty")
            return
        }
        let million = 1000000.00
        let thousand = 1000.00
        // Format population
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        if (pop/million >= 100) {
            // When population is bigger than 100 million
            formatter.maximumFractionDigits = 0
            formatter.currencySymbol = ""
            self.populationLabel.text = formatter.string(from: NSNumber(value: pop/million))! + "M"
        } else if (pop/million >= 1) {
            // When population is bigger than 1 million
            formatter.maximumFractionDigits = 1
            formatter.currencySymbol = ""
            self.populationLabel.text = formatter.string(from: NSNumber(value: pop/million))! + "M"
        } else if (pop/thousand >= 100){
            // When population is bigger than 1000 thousands
            formatter.maximumFractionDigits = 0
            formatter.currencySymbol = ""
            self.populationLabel.text = formatter.string(from: NSNumber(value: pop/thousand))! + "K"
        } else if (pop/thousand >= 1){
            // When population is bigger than 1 thousand
            formatter.maximumFractionDigits = 1
            formatter.currencySymbol = ""
            self.populationLabel.text = formatter.string(from: NSNumber(value: pop/thousand))! + "K"
        } else {
            // When population is less than 1 thousand
            formatter.maximumFractionDigits = 0
            formatter.currencySymbol = ""
            self.populationLabel.text = formatter.string(from: NSNumber(value: pop))!
        }
    }
    
    // Init income label
    func initIncomeLabel() {
        guard let income = self.income else
        {
            print("### ERROR: age empty")
            return
        }
        // Format income
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        self.incomeLabel.text = formatter.string(from: NSNumber(value: income))!
    }
    
    // Init age label
    func initAgeLabel() {
        guard let age = self.age else
        {
            print("### ERROR: age empty")
            return
        }
        self.ageLabel.text = String(format: "%.1f", age)
    }
    
    // Initialize card scroll view
    func initCardScrollView() {
        self.view.backgroundColor = UIColor.white
        cardtScrollView.delegate = self
        cardtScrollView.contentSize = CGSize(width: 1125, height: 385)
        cardtScrollView.showsHorizontalScrollIndicator = false
        cardtScrollView.isPagingEnabled = true
        cardtScrollView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    // Initialize search view
    func initSearchView() {
        searchTable.delegate = self
        searchTable.dataSource = self
        searchBar.delegate = self
        //        initShadow(searchView)
        customizeSearchBar()
    }
    
    // Initialize card views
    func initCardViews() {
        self.initIncomeCardView()
        self.initAgeCardView()
        self.initPropertyCardView()
        // Scroll to left
        self.cardtScrollView.scrollToLeft(animated: false)
        // Scroll hint - hint the user that they can do scroll
        //        self.cardtScrollView.scrollHint(animated: true)
    }
    
    
    // Initialize income card view
    func initIncomeCardView() {
        if self.incomeCardView != nil {
            self.incomeCardView.removeFromSuperview()
        }
        self.incomeCardView = IncomeCardView(locationID, bookmark: false)
        self.cardtScrollView.addSubview(self.incomeCardView)
        //        let incomeLabel: UILabel = UILabel(frame: CGRect(x: 30, y: 30, width: 300, height: 30))
        //        incomeLabel.text = "YEAR: \(self.incomeYears[0])"
        //        incomeCardView.backgroundColor = UIColor.lightGray
        //        incomeCardView.layer.cornerRadius = 25
        //        incomeCardView.addSubview(incomeLabel)
        //        cardtScrollView.addSubview(incomeCardView)
    }
    
    // Initialize income card view
    func initAgeCardView() {
        if self.ageCardView != nil {
            self.ageCardView.removeFromSuperview()
        }
        self.ageCardView = AgeCardView(locationID, bookmark: false)
        self.cardtScrollView.addSubview(self.ageCardView)
    }
    
    // Initialize income card view
    func initPropertyCardView() {
        if self.propertyCardView != nil {
            self.propertyCardView.removeFromSuperview()
        }
        self.propertyCardView = PropertyCardView(locationID, bookmark: false)
        self.cardtScrollView.addSubview(self.propertyCardView)
    }
    
    // Initialize shadow for a view
    func initShadow(_ view: UIView) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.7
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 2
        view.layer.shouldRasterize = true
    }
    
    // Dismiss network oopus view
    @IBAction func dismissNetworkOopusView(_ sender: Any) {
        print("### Button Tapped: dismissNetworkOopusView")
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.networkOopusView.center = CGPoint(x: self.view.center.x, y: -200)
        }) {(true) -> Void in}
    }
    
    // Search display button tapped
    @IBAction func searchDisplayButtonTapped(_ sender: Any) {
        print("### Button Tapped: searchDisplayButtonTapped")
        if (searchActive == false) {
            self.showSearchView() // show search view
        } else {
            self.hideSearchView() // hide search view
        }
    }
    
    // Show search view
    func showSearchView() {
        // Display keyboard
        self.searchBar.endEditing(false)
        // Move to the screen
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.searchView.center = CGPoint(x: 187, y: 300)
        }) { (true) in
            // Reset searcb result
            self.searchResults.removeAll()
            self.searchTable.reloadData()
            self.searchActive = true
            print("### hideSearchView DONE")
        }
    }
    // Hide search view
    func hideSearchView() {
        // Dismiss keyboard
        self.searchBar.endEditing(true)
        // Move to the bottom
        UIView.animate(withDuration: 0.5, animations: {
            () -> Void in
            self.searchView.center = CGPoint(x: 187, y: 793)
        }) { (true) in
            // Reset searcb result
            self.searchResults.removeAll()
            self.searchTable.reloadData()
            self.searchActive = false
            print("### hideSearchView DONE")
        }
    }
    
    
    //
    // - MARK: Search Table
    //
    // # of section
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // # of cells/rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }
    // Create cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Set text for the reusuable table cell
        let cell: SearchTableCell = tableView.dequeueReusableCell(withIdentifier: "searchTableCell", for: indexPath) as! SearchTableCell
        print("### Cell # \(indexPath.row) created")
        // Set text for cell
        cell.searchTableCellText.text = self.searchResults[indexPath.row][1]
        return cell
    }
    // Tap cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("### Cell # \(indexPath.row) tapped, text: \(searchResults[indexPath.row][1])")
        // Set location and location ID
        self.location = searchResults[indexPath.row][1]
        self.locationID = searchResults[indexPath.row][0]
        // Finish and hide search view
        hideSearchView()
    }
    // Disable cell editing
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    //
    // - MARK: Search Bar
    //
    // Begin editing
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        //        searchActive = true
        print("### searchBarTextDidBeginEditing")
    }
    // End editing
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //        searchActive = false
        print("### searchBarTextDidEndEditing")
    }
    // Cancel clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //        searchActive = false
        print("### searchBarCancelButtonClicked")
    }
    // Search clicked
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != nil {
            getSearchResults(searchBar.text!) {
                () in
                self.searchTable.reloadData()
            }
        }
        //        searchActive = false
        print("### searchBarSearchButtonClicked")
    }
    // Search text changed
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("### Live search: \(searchText)")
        getSearchResults(searchText) {
            () in
            self.searchTable.reloadData()
        }
        print("### textDidChange")
    }
    // Customize search bar appearnace
    func customizeSearchBar() {
        // Set search text field text color when idel
        let placeholderAttributes: [String : AnyObject] = [NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        let attributedPlaceholder: NSAttributedString = NSAttributedString(string: "Where would you go?", attributes: placeholderAttributes)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).attributedPlaceholder = attributedPlaceholder
        // Set search text field search icon color
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        let imageV = textFieldInsideSearchBar?.leftView as! UIImageView
        imageV.image = imageV.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageV.tintColor = UIColor.white
        // Set serch text field typing color
        textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    
    //
    // - MARK: Network
    //
    // Get location id from location name
    func getLocationId(_ location: String, completion: @escaping () -> Void) {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        // Load URL and parse response
        sharedDM.getLocationIdWithSuccess(location) { (data) -> Void in
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data)
            } catch {
                print(error)
                print("### Error 0")
                return
            }
            // Retrieve top level dictionary
            guard let dictionary = json as? [String: Any] else {
                print("### Error getting top level dictionary from JSON")
                return
            }
            // Retrieve data feed
            guard let dataFeed = DataFeed(json: dictionary) else {
                print("### Error getting data feed from JSON")
                return
            }
            // Retrieve location ID
            let dataFeedConveretd = dataFeed.dataFeed as! [[AnyObject]]
            self.locationID = dataFeedConveretd[0][0] as! String
            print("### Retrieve Data Finished")
            // Back to the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Get search results from search term
    func getSearchResults(_ searchTerm: String, completion: @escaping () -> Void) {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        // Replace space with underscore if any
        let cleanedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "_")
        // Load URL and parse response
        sharedDM.getSearchResultsWithSuccess(cleanedSearchTerm) { (data) -> Void in
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data)
            } catch {
                print(error)
                print("### Error 0")
                return
            }
            // Retrieve top level dictionary
            guard let dictionary = json as? [String: Any] else {
                print("### Error getting top level dictionary from JSON")
                return
            }
            // Retrieve data feed
            guard let dataFeed = DataFeed(json: dictionary) else {
                print("### Error getting data feed from JSON")
                return
            }
            // Retrieve search results
            let dataFeedConveretd = dataFeed.dataFeed as! [[AnyObject]]
            // Reset search results
            self.searchResults.removeAll()
            // Append search results
            for subFeed in dataFeedConveretd {
                self.searchResults.append([subFeed[0] as! String, subFeed[4] as! String])
            }
            print("### Retrieve search result finished")
            // Back to the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Get population, medium household income and medium age from location ID
    func getLocationSummary(_ locationId: String, completion: @escaping () -> Void) {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        // Load URL and parse response
        sharedDM.getLocatoinSummaryWithSuccess(locationId) { (data) -> Void in
            var json: Any
            do {
                json = try JSONSerialization.jsonObject(with: data)
            } catch {
                print(error)
                print("### Error 0")
                return
            }
            // Retrieve top level dictionary
            guard let dictionary = json as? [String: Any] else {
                print("### Error getting top level dictionary from JSON")
                return
            }
            // Retrieve data feed
            guard let dataFeed = DataFeed(json: dictionary) else {
                print("### Error getting data feed from JSON")
                return
            }
            // Retrieve location summary
            let dataFeedConveretd = dataFeed.dataFeed as! [[AnyObject]]
            // Append location summary
            self.population = dataFeedConveretd[0][4] as! Double
            self.income = dataFeedConveretd[0][8] as! Double
            self.age = dataFeedConveretd[0][2] as! Double
            print("### Retrieve location summary finished")
            // Back to the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Splash screen
    func showSplashScreen() {
        if splashScreen {
            // To show splash screen only once
            splashScreen = false
            
            // Position
            let center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
            let top = CGPoint(x: self.view.center.x, y: 0)
            
            // Create splash view
            let splashTop = UIView(frame: self.view.frame)
            splashTop.backgroundColor = UIColor.white
            
            // Create circle
            let circle = UIView()
            circle.center = top
            circle.backgroundColor = ColorPalette.lightBlue400
            circle.clipsToBounds = true
            
            // Create labels
            let mainLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
            let font = mainLabel.font.fontName
            mainLabel.center = center
            mainLabel.textColor = UIColor.white
            mainLabel.font = UIFont(name: font + "-Bold", size: 25)
            mainLabel.textAlignment = .center
            mainLabel.text = "  POCKET USA"
            let squareLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 15))
            squareLabel.center = CGPoint(x: center.x - 95, y: center.y)
            squareLabel.backgroundColor = UIColor.white
            let subLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 20))
            subLabel.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 60)
            subLabel.textColor = UIColor.white
            subLabel.font = UIFont(name: font + "-Bold", size: 12)
            subLabel.textAlignment = .center
            subLabel.text = "BY: WEI HUANG @ UCHICAGO"
            
            // Add views
            splashTop.addSubview(circle)
            splashTop.addSubview(squareLabel)
            splashTop.addSubview(mainLabel)
            splashTop.addSubview(subLabel)
            self.view.addSubview(splashTop)
            
            // Animte
            UIView.animate(withDuration: 3, animations: {
                circle.frame = CGRect(x: top.x, y: top.y, width: 800, height: 800)
                circle.layer.cornerRadius = 400
                circle.center = top
            }) {
                _ in
                UIView.animate(withDuration: 2, animations: {
                    splashTop.alpha = 0
                    circle.frame = CGRect(x: top.x, y: top.y, width: 100, height: 100)
                    circle.layer.cornerRadius = 400
                    circle.center = top
                }) {
                    _ in
                    splashTop.removeFromSuperview()
                    self.showInstruction()
                }
            }
            
        }
    }
    
    // Delay exection
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // Initialize setting bundle
    func initSetting() {
        let userDefaults = UserDefaults.standard
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        if userDefaults.string(forKey: "Initial Launch") == nil {
            let defaults = ["Developer" : "Wei Huang", "Initial Launch" : "\(formatter.string(from: date))"]
            // Register default values for setting
            userDefaults.register(defaults: defaults)
            userDefaults.synchronize()
        }
        
        print("### DEFAULT: \(userDefaults.dictionaryRepresentation())")
        
        // Register for notification about settings changes
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ViewController.defaultsChanged),
                                               name: UserDefaults.didChangeNotification,
                                               object: nil)
    }
    
    // Stop listening for notifications when view controller is gone
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func defaultsChanged() {
        print("### Setting Default Change")
    }
    
    // Instruction alert
    func showInstruction() {
        let title = "THE HARD PART"
        let message = "(1) Swipe right to reveal side menu.\n (2) Swipe on the chart to see next one. \n (3) Tap 'SEARCH' to explore any location. \n (4) Swipe left to navigate back to last screen."
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Nailed It",
                                   style: .default,
                                   handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWebView" {
            let destinationVC = segue.destination as! WebViewController
            print("### Segue to web view")
            destinationVC.location = self.location
        }
    }
    
    // MARK: - Map
    @IBAction func mapButtonAction(_ sender: Any) {
        let mapLocation = self.location.replacingOccurrences(of: " ", with: "_")
        print("### Location: \(self.location)")
        UIApplication.shared.open(NSURL(string: "http://maps.apple.com/?address=\(mapLocation)")! as URL)
    }
    
    
    
}

extension UIScrollView {
    // Scroll to left end
    func scrollToLeft(animated: Bool) {
        let leftOffset = CGPoint(x: -contentInset.left, y: 0)
        setContentOffset(leftOffset, animated: animated)
    }
    // Scroll hint
    func scrollHint(animated: Bool) {
        let rightOffset = CGPoint(x: contentInset.right, y: 0)
        let leftOffset = CGPoint(x: -contentInset.left, y: 0)
        setContentOffset(rightOffset, animated: animated)
        setContentOffset(leftOffset, animated: animated)
    }
}

extension ViewController: DataManagerDelegate {
    // Show network alert view
    func showNetworkAlert(_ error: Error) {
        print("### Delegate called")
        print("### ERROR: error")
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                () -> Void in
                self.networkOopusView.center = self.view.center
            }) {(true) -> Void in}
        }
    }
}

