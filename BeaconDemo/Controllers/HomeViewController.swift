//
//  HomeViewController.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/10/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BeaconDemo"
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifiers.tableViewCell)
        self.tableView.registerNib(UINib.init(nibName:"UserHeaderTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.CellIdentifiers.userHeaderTableViewCell)
        self.tableView.registerNib(UINib.init(nibName:"StarsDetailTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.CellIdentifiers.starsDetailTableViewCell)

        /*
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
        }
         */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView Delegate methods
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 30
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
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
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else {
            return 1
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 186
        } else if indexPath.section == 1 {
            return 60
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.userHeaderTableViewCell, forIndexPath: indexPath) as! UserHeaderTableViewCell
            return cell
        } else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifiers.starsDetailTableViewCell, forIndexPath: indexPath) as! StarsDetailTableViewCell
            return cell
        } else {
            let cell = UITableViewCell()
            return cell
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
