//
//  IncomeCardView.swift
//  Pocket USA
//
//  Created by Wei Huang on 3/10/17.
//  Copyright © 2017 Wei Huang. All rights reserved.
//

import UIKit
import DataKit

// View of median income chart
class IncomeCardView: UIView {
    
    var margin: Double!
    var barSpacing: Double!
    var topLeftConor: CGPoint!
    var topRightConor: CGPoint!
    var bottomLeftConor: CGPoint!
    var bottomRightConor: CGPoint!
    
    let bookmarkButton = UIButton(frame: CGRect(x: 320, y: 0, width: 50, height: 50))
    let label: UILabel = UILabel(frame: CGRect(x: 25 + 37.5, y: 25 + 100, width: 300, height: 25))
    let barWidth = 0.25
    let barInitialX = 0.25
    var location = ""
    var locationID = ""
    var sourceOrg = ""
    var years = [String]()
    var partentLocationIDs = [String]()
    var locationIDs = [String]()
    var locationNames = [String]()
    var medianIncomes = [Double]()
    var dataFeed = [[AnyObject]]()
    var requestGroup = DispatchGroup()
    
    // Required init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Custom init
    init(_ locationID: String, bookmark: Bool) {
        self.locationID = locationID
        // Create frame
        super.init(frame: CGRect(x: 0, y: 0, width: 375, height: 400 - 15))
        // Initialize bookmark
        initBookmarkButton()
        // Get parent location IDs
        getParentLocationIDs() {
            // Get medium household income
            self.getMediumHouseholdIncome() {
                () -> Void in
                self.parseDataFeed()
                    {
                        () -> Void in
                        self.getLocationNames() {
                            () -> Void in
                            self.drawBars()
                            // Initiate description section
                            self.initDescription()
                        }
                }
            }
        }
//        AppGroupDefaultsManager.sharedInstance.reset()
    }
    
    // Initialize bookmark button
    func initBookmarkButton() {
        addSubview(bookmarkButton)
        bookmarkButton.addTarget(self, action: #selector(bookmarkButtonTapped), for: .touchUpInside)
        let bookmarkID = "income-\(locationID)"
        if AppGroupDefaultsManager.sharedInstance.alreadyAdded(bookmarkID) {
            bookmarkButton.setBackgroundImage(#imageLiteral(resourceName: "Bookmark"), for: .normal)
        } else {
            bookmarkButton.setBackgroundImage(#imageLiteral(resourceName: "UnBookmark"), for: .normal)
        }
    }
    
    func bookmarkButtonTapped(sender: UIButton!) {
        print("### bookmark tapped")
        let bookmarkID = "income-\(locationID)"
        if AppGroupDefaultsManager.sharedInstance.alreadyAdded(bookmarkID) {
            bookmarkButton.setBackgroundImage(#imageLiteral(resourceName: "UnBookmark"), for: .normal)
            AppGroupDefaultsManager.sharedInstance.remove(bookmarkID)
        } else {
            bookmarkButton.setBackgroundImage(#imageLiteral(resourceName: "Bookmark"), for: .normal)
            let sharedItem: NSDictionary = [ "bookmarkID": bookmarkID,
                "locationID": locationID,
                "bookmarkType": "income"
            ]
            AppGroupDefaultsManager.sharedInstance.add(object: sharedItem)
        }
        print("### Current List: \(AppGroupDefaultsManager.sharedInstance.currentList())")
    }
    
    // Initialize shadow
    func initShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 2
        self.layer.shouldRasterize = true
    }
    
    // Get parent location IDs
    func getParentLocationIDs(completion: @escaping () -> Void) {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        DataManager.shared.getParentLocationIDsWithSuccess(locationID) { (data) -> Void in
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
            
            for subFeed in dataFeed.dataFeed! {
                let subFeed = subFeed as! [String]
                self.partentLocationIDs.append(subFeed[0])
                print("### Append parentLocationID: \(subFeed[0]), currentLocationID: \(self.locationID)")
            }
            
            // Back to the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Get medium household income
    func getMediumHouseholdIncome(completion: @escaping () -> Void) {
        URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        DataManager.shared.getMediumDataWithSuccess(self.locationID, self.partentLocationIDs) { (data) -> Void in
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
            // Retrieve source feed
            guard let sourceFeed = SourceFeed(json: dictionary) else {
                print("### Error getting source feed from JSON")
                return
            }
            // Retrieve data feed
            guard let dataFeed = DataFeed(json: dictionary) else {
                print("### Error getting data feed from JSON")
                return
            }
            self.dataFeed = dataFeed.dataFeed as! [[AnyObject]]
            self.sourceOrg = sourceFeed.orgName!
            
            print(sourceFeed.orgName!)
            print("### Retrieve Data Finished")
            
            // Back to the main thread
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Get location name from location ID
    func getLocationNames(completion: @escaping () -> Void) {
        locationNames = [String](repeating: "", count: locationIDs.count)
        for locatoinID in self.locationIDs {
            // Enter dispatch group
            requestGroup.enter()
            URLCache.shared = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
            DataManager.shared.getLocationNameWithSuccess(locatoinID) { (data) -> Void in
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
                // Retrieve location name
                let dataFeedConveretd = dataFeed.dataFeed as! [[AnyObject]]
                // Append location name
                //                self.locationNames.append(dataFeedConveretd[0][2] as! String)
                self.locationNames[self.locationIDs.index(of: dataFeedConveretd[0][7] as! String)!] = dataFeedConveretd[0][2] as! String
                // Leave group
                self.requestGroup.leave()
            }
        }
        // After request group finished, back to the main thread
        requestGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    // Parse data feed
    func parseDataFeed(completion: @escaping () -> Void) {
        // Retrieve data from data Feed
        for subFeed in dataFeed {
            // Retrieve year
            if let year = subFeed[0] as? NSNumber {
                years.append(year.stringValue)
                print("### Year: \(year)")
            } else {print("### ERROR converting year")}
            // Retrieve location id
            if let locationID = subFeed[1] as? NSString {
                locationIDs.append(locationID as String)
                print("### LocationID: \(locationID)")
            } else {print("### ERROR converting LocationID")}
            // Retrieve income figure
            if let income = subFeed[2] as? NSNumber {
                medianIncomes.append(income as! Double)
                print("### Income: \(income)")
            } else {print("### ERROR converting income")}
        }
        //        // Get location names from location IDs
        //        for id in locationIDs {
        //            getLocationName(id)
        //        } ***
        // Back to the main thread
        DispatchQueue.main.async {
            completion()
        }
    }
    
    // Initialize descprtion section
    func initDescription() {
        // Sqaure label
        let squareLabel = UILabel(frame: CGRect(x: Double(topLeftConor.x) - 25, y: Double(topLeftConor.y - 100 + 10), width: 50, height: 25))
        squareLabel.textColor = ColorPalette.lightBlue500
        let squareFont = squareLabel.font.fontName
        squareLabel.font = UIFont(name: squareFont + "-Bold", size: 16)
        squareLabel.text = "\u{25A0}"
        
        // Title label
        let titleLabel = UILabel(frame: CGRect(x: Double(topLeftConor.x), y: Double(topLeftConor.y - 100 + 10), width: 300 - 50, height: 25))
        titleLabel.textColor = UIColor.white
        let titleFont = titleLabel.font.fontName
        titleLabel.font = UIFont(name: titleFont + "-Bold", size: 16)
        //        titleLabel.textAlignment = .center
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 1
        titleLabel.text = "MEDIUM HOUSEHOLD INCOME"
        
        // Text label
        let textLabel = UILabel(frame: CGRect(x: Double(topLeftConor.x), y: Double(topLeftConor.y - 85 + 10), width: 300 - 50, height: 50))
        textLabel.textColor = UIColor.darkGray
        let textfont = textLabel.font.fontName
        textLabel.font = UIFont(name: textfont, size: 10)
        textLabel.adjustsFontSizeToFitWidth = true
        textLabel.numberOfLines = 0
        
        // Check is United States
        if (locationID == "01000US") {
            textLabel.text = "This chart shows the median household income of United States."
        } else {
            textLabel.text = "This chart shows the median household income of \(locationNames[locationIDs.index(of: locationID)!]) compared to its parent locations."
        }
        
        // Source label
        let sourceLabel = UILabel(frame: CGRect(x: Double(bottomLeftConor.x), y: Double(bottomLeftConor.y + 40), width: 300 - 50, height: 15))
        sourceLabel.textColor = UIColor.lightGray
        sourceLabel.font = UIFont(name: textLabel.font.fontName, size: 10)
        sourceLabel.adjustsFontSizeToFitWidth = true
        sourceLabel.numberOfLines = 1
        sourceLabel.text = "Source: Census Bureau, 2015"
        
        // Source sqaure label
        let sourceSquareLabel = UILabel(frame: CGRect(x: Double(bottomLeftConor.x) - 25, y: Double(bottomLeftConor.y + 40), width: 50, height: 15))
        let squareLabelFont = sourceSquareLabel.font.fontName
        sourceSquareLabel.textColor = UIColor.lightGray
        sourceSquareLabel.font = UIFont(name: squareLabelFont + "-Bold", size: 10)
        sourceSquareLabel.text = "\u{25A0}"
        
        self.addSubview(squareLabel)
        self.addSubview(titleLabel)
        self.addSubview(textLabel)
        self.addSubview(sourceSquareLabel)
        self.addSubview(sourceLabel)
    }
}

// - MARK: Drawing
extension IncomeCardView {
    
    // Custom drawing / Background draw
    override func draw(_ rect: CGRect)
    {
        // Initialize variables
        margin = DrawingReference.marginWidth
        barSpacing = DrawingReference.barSpacing
        topLeftConor = CGPoint(x: 37.5 + margin, y: 100 + margin - 15)
        topRightConor = CGPoint(x: Double(rect.maxX) - margin - 37.5, y: 100 + margin - 15)
        bottomLeftConor = CGPoint(x: 37.5 + margin, y: Double(rect.maxY) - margin - 50)
        bottomRightConor = CGPoint(x: Double(rect.maxX) - margin - 37.5, y: Double(rect.maxY) - margin - 50)
        // Draw gray background rec
        let backgroundkShapeGray = CGRect(x: 0, y: 0, width: rect.maxX, height: rect.maxY)
        let backgroundPathGray = UIBezierPath(rect: backgroundkShapeGray)
        #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1).setFill()
        backgroundPathGray.fill() // draw
        
        // Draw white background rec
        //        let backgroundkShape = CGRect(x: 0, y: 75, width: rect.maxX, height: (rect.maxY))
        let backgroundkShapeWhite = CGRect(x: 37.5, y: 100 - 10, width: rect.maxX - 75, height: rect.maxY - 150 + 10)
        let backgroundPathWhite = UIBezierPath(rect: backgroundkShapeWhite)
        UIColor.white.setFill()
        backgroundPathWhite.fill() // draw
        
        // Draw axies
        let axisPath = UIBezierPath()
        UIColor.lightGray.setStroke()
        axisPath.lineWidth = 2
        axisPath.move(to: CGPoint(x: topLeftConor.x-1, y: topLeftConor.y))
        axisPath.addLine(to: CGPoint(x: bottomLeftConor.x-1, y: bottomLeftConor.y))
        axisPath.stroke() // Draw vertical axis
        
        // Initial income label
        let initialIncomeLabel = UILabel(frame: CGRect(x: Double(bottomLeftConor.x) - 15, y: Double(bottomLeftConor.y) + 2, width: 30, height: 14))
        initialIncomeLabel.textColor = ColorPalette.lightGrayA8
        initialIncomeLabel.font = UIFont(name: initialIncomeLabel.font.fontName, size: 10)
        initialIncomeLabel.textAlignment = .center
        initialIncomeLabel.numberOfLines = 1
        initialIncomeLabel.text = "$0"
        self.addSubview(initialIncomeLabel)
    }
    
    func drawBars() {
        print("### Location Names: \(self.locationNames)")
        if (medianIncomes.count > 0) {
            let barLayer = CAShapeLayer()
            let targetBarLayer = CAShapeLayer()
            let barPath = UIBezierPath()
            let targetBarPath = UIBezierPath()
            let barWidth = (Double(bottomLeftConor.y - topLeftConor.y) - barSpacing) / Double(medianIncomes.count) - barSpacing
            var newEndX: Double!
            var newStartY: Double!
            // Set layer colors
            barLayer.strokeColor = ColorPalette.lightGrayA8.cgColor
            targetBarLayer.strokeColor = ColorPalette.lightBlue500A8.cgColor
            barLayer.fillColor = nil
            targetBarLayer.fillColor = nil
            // Set Bar width
            barLayer.lineWidth = CGFloat(barWidth)
            targetBarLayer.lineWidth = CGFloat(barWidth)
            var index = 0.0 // index of current income
            // Log
            print("### locationIDs: \(locationIDs)")
            print("### locationID: \(locationID)")
            // Location labels
            var locationLabels = [UILabel]()
            // Draw guiding lines
            drawGuidingLines(medianIncomes.max()!)
            // Create income bars paths and labels
            for income in medianIncomes {
                print("### Bar \(index) - income, max income: \(income), \(medianIncomes.max()!)")
                newEndX = Double(topLeftConor.x) + Double(income / medianIncomes.max()!) * (Double(topRightConor.x - topLeftConor.x) /* - barSpacing */ /*- topLeftConor.x */)
                newStartY = Double(topLeftConor.y) + (index+1) * barSpacing + (index+0.5) * barWidth
                // When bar is for the target location
                if (Int(index) == locationIDs.index(of: locationID)) {
                    print("### locationID: \(String(describing: locationIDs.index(of: locationID))), index: \(index)")
                    // Create path for the target layer
                    targetBarPath.move(to: CGPoint(x: Double(topLeftConor.x), y: newStartY))
                    targetBarPath.addLine(to: CGPoint(x: newEndX, y: newStartY))
                } else {
                    barPath.move(to: CGPoint(x: Double(topLeftConor.x), y: newStartY))
                    barPath.addLine(to: CGPoint(x: newEndX, y: newStartY))
                }
                // Create label
                let locationLabel = UILabel(frame: CGRect(x: Double(topLeftConor.x) + 5, y: newStartY - barWidth/2, width: newEndX - Double(topLeftConor.x), height: barWidth))
                locationLabel.textColor = UIColor.white
                locationLabel.font = UIFont(name: locationLabel.font.fontName, size: 12)
                locationLabel.adjustsFontSizeToFitWidth = true
                locationLabel.numberOfLines = 1
                locationLabel.text = locationNames[Int(index)]
                locationLabels.append(locationLabel)
                index += 1
                print("### drawBars DONE")
            }
            // Add paths to layers
            barLayer.path = barPath.cgPath
            targetBarLayer.path = targetBarPath.cgPath
            // Add annimation
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0.0
            animation.toValue = 1.0
            animation.duration = 1.0
            barLayer.add(animation, forKey: "drawLineAnimation")
            targetBarLayer.add(animation, forKey: "drawLineAnimation")
            self.layer.addSublayer(barLayer)
            self.layer.addSublayer(targetBarLayer)
            for label in locationLabels {
                self.addSubview(label)
            }
        }
    }
    
    // Draw guiding lines
    func drawGuidingLines(_ maxIncome: Double) {
        let guideLinesLayer = CAShapeLayer()
        let guideLinePath = UIBezierPath()
        let lineCount = Int(floor(medianIncomes.max()! / 10000))
        guideLinesLayer.fillColor = nil
        guideLinesLayer.lineWidth = 1
        guideLinesLayer.strokeColor = ColorPalette.lightGrayA5.cgColor
        for var i in 1...lineCount {
            let newX = Double(topLeftConor.x) + Double(i * 10000)/maxIncome * (Double(topRightConor.x - topLeftConor.x) /* - barSpacing */)
            // Craete Line
            guideLinePath.move(to: CGPoint(x: newX, y: Double(topLeftConor.y)))
            guideLinePath.addLine(to: CGPoint(x: newX, y: Double(bottomLeftConor.y)))
            // Create label
            if (i % 2 == 0) {
                let incomeLabel = UILabel(frame: CGRect(x: newX - 15, y: Double(bottomLeftConor.y) + 2, width: 30, height: 14))
                incomeLabel.textColor = ColorPalette.lightGrayA8
                incomeLabel.font = UIFont(name: incomeLabel.font.fontName, size: 10)
                incomeLabel.textAlignment = .center
                incomeLabel.numberOfLines = 1
                incomeLabel.text = "$" + String(i * 10) + "K"
                self.addSubview(incomeLabel)
            }
            i += 1
        }
        // Add paths to layers
        guideLinesLayer.path = guideLinePath.cgPath
        // Add annimation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = 1.0
        guideLinesLayer.add(animation, forKey: "drawLineAnimation")
        self.layer.addSublayer(guideLinesLayer)
    }
}
