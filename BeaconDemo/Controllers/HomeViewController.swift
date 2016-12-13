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
    private var isLoading: Bool = true
    private var hasErrors: Bool = false
    private var hasNoRows: Bool = false
    private var stars : [BDStars]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BeaconDemo"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.tableViewCell)
        self.tableView.registerNib(UINib.init(nibName:"StarsDetailTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.CellIdentifiers.starsDetailTableViewCell)
        self.setupUserInfo()
        self.addObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.userProfileImageView.layer.cornerRadius = self.userProfileImageView.bounds.size.width / 2
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeObservers()
    }
    
    // MARK: Private methods
    
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
                self.userNameLabel.text = currentUser["name"] as! String
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
                    
                } else {
                    self.hasNoRows = true
                }
                self.isLoading = false
                self.hasErrors = false
                self.tableView.reloadData()
            } else {
                self.isLoading = false
                self.hasErrors = true
                self.hasNoRows = false
                self.tableView.reloadData()
            }
        }
    }
    
    private func addObservers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleDidEnterRegion), name: Constants.Notifications.didEnterBeaconRegion, object: nil)
    }
    
    private func removeObservers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc private func handleDidEnterRegion() {
        NSLog("Did enter beacon region!")
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
            titleLabel.text = "Estrellas ganadas por negocio"
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
