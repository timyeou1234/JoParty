//
//  LoginViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/27.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit



class LoginViewController: UIViewController {

    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    let loginView : FBSDKLoginButton = FBSDKLoginButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginView.hidden = true
        FIRAuth.auth()?.addAuthStateDidChangeListener{ auth, user in
            if let user = user{
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let userDetailView: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("UserDetailView")
                self.performSegueWithIdentifier("logInSegue", sender: nil)
            }else{
            self.loginView.hidden = false
            self.view.addSubview(self.loginView)
            self.loginView.center = self.view.center
            self.loginView.readPermissions = ["public_profile", "email", "user_friends"]
            self.loginView.delegate = self
            }
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension LoginViewController: FBSDKLoginButtonDelegate{
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        
        loginSpinner.startAnimating()
        self.loginView.hidden = true
        let credental = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
                
        FIRAuth.auth()?.signInWithCredential(credental){
            (user, error) in
            if error != nil{
                print(error!.localizedDescription)
                self.loginSpinner.stopAnimating()
                do {
                    try FIRAuth.auth()?.signOut()
                }catch{
                    print(error)
                }

                return
            }else if result.isCancelled{
                self.loginView.hidden = false
                self.loginSpinner.stopAnimating()
                self.viewWillAppear(false)
            }else{
                let email = user?.email
                let userName = user?.displayName
                let photoUrl = user?.photoURL
                var userValue = ["userName": userName!, "email": email!, "photoUrl":String(photoUrl!)]
                
                if let pushToken = NSUserDefaults.standardUserDefaults().objectForKey("UserPushToken"){
                    userValue["pushToken"] = "\(pushToken)"
                }
                let ref = FIRDatabase.database().reference()
                ref.child("User").child((user?.uid)!).setValue(userValue)
            }
        }
        
    }
    
    
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
        }catch{
            print(error)
        }
    }
    
    func returnUserData()
    {
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                print("fetched user: \(result)")
                let userName : NSString = result.valueForKey("name") as! NSString
                print("User Name is: \(userName)")
                let userEmail : NSString = result.valueForKey("email") as! NSString
                print("User Email is: \(userEmail)")
            }
        })
    }
}




