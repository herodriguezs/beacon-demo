//
//  LoginViewController.swift
//  BeaconDemo
//
//  Created by Hugo Rodriguez on 12/10/16.
//  Copyright © 2016 Clinpays. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var separatorView: UIView!
    
    var loginButton: LoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createFacebookLoginButton()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Private methods
    
    private func createFacebookLoginButton() {
        loginButton = LoginButton.init(frame: nil, readPermissions: [ReadPermission.Email, ReadPermission.PublicProfile])
        loginButton.delegate = self
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        // Add Constraints
        loginButton.topAnchor.constraintEqualToAnchor(self.separatorView.bottomAnchor, constant: 20).active = true
    }
    
    // MARK: Facebook Login Button Delegate methods
    
    func loginButtonDidCompleteLogin(loginButton: LoginButton, result: LoginResult) {
        // Getting login result failed due to missing shared keychain entitlement.
        // Fixed on xcode 8.2.
        
    }
    
    func loginButtonDidLogOut(loginButton: LoginButton) {
        
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
