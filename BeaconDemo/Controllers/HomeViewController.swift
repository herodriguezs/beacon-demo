//
//  HomeViewController.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/10/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import Parse
import FacebookCore
import FacebookLogin

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak private var imageViewActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var userProfileImageView: UIImageView!
    @IBOutlet weak private var userNameLabel: UILabel!
    @IBOutlet weak private var winButton: UIButton!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    private var isLoading: Bool = true
    private var hasErrors: Bool = false
    private var hasNoRows: Bool = false
    private var stars : [BDStars]?
    private var winButtonIsEnabled : Bool = false
    private var currentBusiness : BDBusiness!
    private var refreshControl : UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BeaconDemo"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.tableViewCell)
        self.tableView.registerNib(UINib.init(nibName:"StarsDetailTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.CellIdentifiers.starsDetailTableViewCell)
        self.setupUserInfo()
        self.addObservers()
        self.initialize()
        self.disableWinButton()
        self.startMonitoring()
        self.addRefreshControl()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.size.width / 2
        self.winButton.layer.cornerRadius = 5.0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }
    
    // MARK: Private methods
    
    private func initialize() {
        self.winButton.setTitle(Constants.Messages.winButtonEnabled, forState: .Normal)
        self.winButton.setTitle(Constants.Messages.winButtonDisabled, forState: .Disabled)
    }
    
    private func startMonitoring() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.startMonitoringRegion()
    }
    
    private func addRefreshControl() {
        self.refreshControl.addTarget(self, action:#selector(refreshTableView), forControlEvents: UIControlEvents.ValueChanged)
        let tableViewController = UITableViewController()
        tableViewController.tableView = self.tableView
        tableViewController.refreshControl = self.refreshControl
    }
    
    @objc private func refreshTableView() {
        self.resetAllVariables()
        self.loadUserStars()
    }
    
    private func setupUserInfo() {
        self.getFacebookUserInformation()
    }
    
    private func getFacebookUserInformation() {
        if Util.notLoggedIn() {
            return
        }
        let currentUser = PFUser.currentUser()!

        let connection = GraphRequestConnection()
        connection.add(GraphRequest(graphPath: "/me")) { httpResponse, result in
            switch result {
            case .Success(let response):
                print("Graph Request Succeeded: \(response.dictionaryValue)")
                currentUser["name"] = response.dictionaryValue!["name"]
                self.userNameLabel.text = currentUser["name"] as? String
            case .Failed(let error):
                print("Graph Request Failed: \(error)")
            }
        }
        connection.start()
        
        self.imageViewActivityIndicator.startAnimating()
        let pictureConnection = GraphRequestConnection()
        pictureConnection.add(GraphRequest(graphPath: "me/picture?type=large&redirect=false")) { httpResponse, result in
            switch result {
            case .Success(let response):
                let responseDictionary = response.dictionaryValue!["data"] as! [String : AnyObject]
                currentUser["picture_url"] = responseDictionary["url"]
                
                let url = NSURL(string: currentUser["picture_url"] as! String)
                let data = NSData(contentsOfURL:url!)
                if data != nil {
                    self.userProfileImageView.image = UIImage(data:data!)
                }
                
            case .Failed(let error):
                print("Graph Request Failed: \(error)")
                self.userProfileImageView.image = UIImage(named: "facebook-default-no-profile-pic")
            }
            
            self.imageViewActivityIndicator.stopAnimating()

        }
        pictureConnection.start()
    }
    
    private func resetAllVariables() {
        self.isLoading = true
        self.hasErrors = false
        self.hasNoRows = false
    }
    
    private func loadUserStars() {
        let query = PFQuery(className: BDStars.parseClassName())
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.findObjectsInBackgroundWithBlock { (stars : [PFObject]?, error: NSError?) in
            if error == nil {
                if stars != nil && stars?.count > 0 {
                    self.stars = stars as? [BDStars]
                } else {
                    self.hasNoRows = true
                }
                self.isLoading = false
                self.hasErrors = false
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            } else {
                self.isLoading = false
                self.hasErrors = true
                self.hasNoRows = false
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    private func enableWinButton() {
        self.winButton.enabled = true
        self.winButton.alpha = 1.0
        self.winButtonIsEnabled = true
    }
    
    private func disableWinButton () {
        self.winButton.enabled = false
        self.winButton.alpha = 0.5
        self.winButtonIsEnabled = false
    }
    
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDidEnterRegion), name: Constants.Notifications.didEnterBeaconRegion, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDidExitBeaconRegion), name: Constants.Notifications.didExitBeaconRegion, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleInsideBeaconRegion), name: Constants.Notifications.insideBeaconRegion, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleOutsideBeaconRegion), name: Constants.Notifications.outsideBeaconRegion, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleUnknowBeaconRegion), name: Constants.Notifications.unknownBeaconRegion, object: nil)
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleDidEnterRegion() {
        self.enableWinButton()
    }
    
    @objc private func handleDidExitBeaconRegion() {
        self.disableWinButton()
    }
    
    @objc private func handleInsideBeaconRegion() {
        self.enableWinButton()
    }
    
    @objc private func handleOutsideBeaconRegion() {
        self.disableWinButton()
    }
    
    @objc private func handleUnknowBeaconRegion() {
        self.disableWinButton()
    }
    
    private func showLoadingView() {
        self.loadingView.hidden = false
        self.loadingView.alpha = 0.0
        self.loadingActivityIndicator.startAnimating()
        
        UIView.animateWithDuration(0.5, animations: { 
            self.loadingView.alpha = 1.0
        })
    }
    
    private func hideLoadingView(completion: () -> Void) {
        UIView.animateWithDuration(0.5, animations: {
            self.loadingView.alpha = 0.0
        }) { (finished: Bool) in
            if finished {
                self.loadingActivityIndicator.stopAnimating()
                self.loadingView.hidden = true
                completion()
            }
        }
    }
    
    private func saveStarsForBusiness(business: BDBusiness, completion: (success: Bool, error: NSError?) -> Void) {
        self.findBusiness(business, completion: { (business: PFObject?, error: NSError?) -> Void in
            if business != nil {
                self.currentBusiness = business as! BDBusiness
                self.addStarsTo(business as! BDBusiness, completion: { (stars: PFObject?, error: NSError?) -> Void in
                    if error == nil && stars != nil {
                        let stars = stars as! BDStars
                        stars.amount = stars.amount + 1
                        stars.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if error == nil {
                                completion(success: true, error: nil)
                            } else {
                                completion(success: false, error: error)
                            }
                        })
                    } else {
                        let stars = BDStars()
                        let business = business as! BDBusiness
                        stars.businessId = business.id
                        stars.user = PFUser.currentUser()!
                        stars.amount = 1
                        stars.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                            if error == nil {
                                completion(success: true, error: nil)
                            } else {
                                completion(success: false, error: error)
                            }
                        })
                    }
                })
            } else {
                self.create(self.currentBusiness, completion: { (business, error) in
                    self.addStarsTo(business as! BDBusiness, completion: { (stars: PFObject?, error: NSError?) -> Void in
                        if error == nil && stars != nil {
                            let stars = stars as! BDStars
                            stars.amount = stars.amount + 1
                            stars.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                                if error == nil {
                                    completion(success: true, error: nil)
                                } else {
                                    completion(success: false, error: error)
                                }
                            })
                        } else {
                            let stars = BDStars()
                            let business = business as! BDBusiness
                            stars.businessId = business.id
                            stars.user = PFUser.currentUser()!
                            stars.amount = 1
                            stars.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) in
                                if error == nil {
                                    completion(success: true, error: nil)
                                } else {
                                    completion(success: false, error: error)
                                }
                            })
                        }
                    })
                })
            }
        })
    }
    
    private func findBusiness(business : BDBusiness, completion: (business: PFObject?, error: NSError?) -> Void) {
        let query = PFQuery(className: BDBusiness.parseClassName())
        query.whereKey("id", equalTo: business.id)
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) in
            if error == nil && objects?.count > 0 {
                if let businessFound : PFObject = objects![0] {
                    completion(business: businessFound as! BDBusiness, error: nil)
                } else {
                    completion(business: nil, error: nil)
                }
            } else {
                completion(business: nil, error: error)
            }
        }
    }
    
    private func create(business: BDBusiness, completion: (business: PFObject?, error : NSError?) -> Void) {
        business.name = "Comercio \(business.id)"
        business.saveInBackgroundWithBlock { (success: Bool, error: NSError? ) in
            if success {
                completion(business: business, error: nil)
            } else {
                completion(business: nil, error: error)
            }
        }
    }
    
    private func addStarsTo(business : BDBusiness, completion: (stars: PFObject?, error: NSError?) -> Void) {
        self.findStarsFor(business) { (stars, error) in
            if error == nil {
                completion(stars: stars, error: nil)
            } else {
                completion(stars: nil, error: error)
            }
        }
    }
    
    private func findStarsFor(business: BDBusiness, completion: (stars: PFObject?, error: NSError?) -> Void) {
        let query = PFQuery(className: BDStars.parseClassName())
        query.whereKey("businessId", equalTo: business.id)
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock { (stars: [PFObject]? , error: NSError?) in
            if error == nil && stars?.count > 0 {
                if let starsFound : PFObject = stars![0] {
                    completion(stars: starsFound as! BDStars, error: nil)
                } else {
                    completion(stars: nil, error: nil)
                }
            } else {
                completion(stars: nil, error: error)
            }
        }
    }
    
    // MARK: UITableView Delegate methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView.init(frame: CGRectMake(0, 0, tableView.bounds.size.width, 30))
            headerView.backgroundColor = Constants.Colors.lightGray
            
            
            let titleLabel = UILabel.init(frame: CGRectMake(16, 0, headerView.bounds.size.width - 32, headerView.bounds.size.height))
            titleLabel.text = "Estrellas"
            titleLabel.font = UIFont.systemFontOfSize(12.0)
            titleLabel.textColor = Constants.Colors.gray
            titleLabel.textAlignment = NSTextAlignment.Left
            
            headerView.addSubview(titleLabel)
            
            return headerView
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.isLoading || self.hasErrors || self.hasNoRows ? 2 : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.stars != nil ? (self.stars?.count)! : 0
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.starsDetailTableViewCell, forIndexPath: indexPath) as! StarsDetailTableViewCell
            cell.setupCell(withStars: self.stars![indexPath.row])
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.tableViewCell, forIndexPath: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            for subview in cell.subviews {
                subview.removeFromSuperview()
            }
            if self.isLoading {
                let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                activityIndicatorView.center = CGPointMake(cell.center.x, cell.bounds.size.height / 2)
                activityIndicatorView.startAnimating()
                cell.addSubview(activityIndicatorView)
                self.loadUserStars()
            } else if self.hasErrors {
                let label = UILabel(frame: CGRectMake(20, 0, cell.bounds.size.width - 40, cell.bounds.size.height))
                label.font = label.font.fontWithSize(14)
                label.textColor = Constants.Colors.textDark
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.minimumScaleFactor = 0.8
                label.text = Constants.Messages.defaultError
                cell.addSubview(label)
            } else if self.hasNoRows {
                let label = UILabel(frame: CGRectMake(20, 0, cell.bounds.size.width - 40, cell.bounds.size.height))
                label.font = label.font.fontWithSize(14)
                label.textColor = Constants.Colors.textDark
                label.textAlignment = .Center
                label.numberOfLines = 0
                label.minimumScaleFactor = 0.8
                label.text = Constants.Messages.noStarsError
                cell.addSubview(label)
            }
            return cell;
        }
    }

    // MARK: IBAction methods
    
    @IBAction private func winButtonPressed(sender: AnyObject) {
        let randomBusinessId = arc4random_uniform(5) + 1
        self.currentBusiness = BDBusiness()
        self.currentBusiness.id = Int(randomBusinessId)
        
        self.showLoadingView()
        self.saveStarsForBusiness(self.currentBusiness) { (success, error) in
            self.hideLoadingView({ 
                if error == nil {
                    Util.showAlert(withMessage: "Excelente! Has ganado 1 estrella para el negocio '\(self.currentBusiness.name)'", inViewController: self)
                    self.refreshTableView()
                } else {
                    Util.showAlert(withMessage: Constants.Messages.defaultError, inViewController: self)
                }
            })
        }
    }
    
    @IBAction private func logoutButtonPressed(sender: AnyObject) {
        let alertController = UIAlertController(title: "", message: "¿Está seguro que desea cerrar sesión?", preferredStyle: .ActionSheet)
        let logoutAction = UIAlertAction(title: "Cerrar Sesión", style: .Destructive) { (action : UIAlertAction) in
            PFUser.logOut()
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.showLoginViewController()
        }
        alertController.addAction(logoutAction)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .Cancel, handler:nil)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true) {}
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
