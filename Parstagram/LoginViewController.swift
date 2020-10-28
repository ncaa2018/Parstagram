//
//  LoginViewController.swift
//  Parstagram
//
//  Created by loan on 10/27/20.
//  Copyright © 2020 naomia2022@hotmail.com. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success,error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil) //go to feed
            }
            else{
                print("Error: \(error?.localizedDescription)")
            }
        }
        
    }
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in //either we have a user or its nil
            if user != nil { //successful logged in
                self.performSegue(withIdentifier: "loginSegue", sender: nil) //go to feed
            }
            else{
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        passwordField.isSecureTextEntry = true
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
