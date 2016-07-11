//
//  UserDetailViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/29.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseStorage

class UserDetailViewController: UIViewController {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    
    @IBAction func logoutButton(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKAccessToken.setCurrentAccessToken(nil)
        FBSDKProfile.setCurrentProfile(nil)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("UserPushToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
            
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginView: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("LoginView")
        
        self.presentViewController(loginView, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userPic.backgroundColor = UIColor.grayColor()
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            let email = user.email
            let photoUrl = user.photoURL
            let uid = user.uid
            
            nameLable.text = name
//            userPic.image = UIImage(data: NSData(contentsOfURL: photoUrl!)!)
            
            CurrentUser.user.name = name
            CurrentUser.user.uid = uid
            CurrentUser.user.email = email
            
            let storage = FIRStorage.storage()
            let storageRef = storage.referenceForURL("gs://joinme2theparty.appspot.com")
            let profilePicRef = storageRef.child(user.uid + "/profile.jpg")
            
            
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print("Dowload exixt issue")
                } else {
                    // Data for "images/island.jpg" is returned
                    // ... let islandImage: UIImage! = UIImage(data: data!)
                    self.userPic.image = UIImage(data: data!)
                    CurrentUser.user.selfieImage = data!
                }
            }
            
            if self.userPic.image == nil{
                
                let profilePic: FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": 300, "redirect": false], HTTPMethod: "GET")
                profilePic.startWithCompletionHandler({
                    (connection, result, error) -> Void in
                    
                    if error == nil{
                        let dictionary = result as? NSDictionary
                        let data = dictionary?.objectForKey("data")
                        
                        let urlPic = (data?.objectForKey("url")) as! String
                        
                        if let imageData = NSData(contentsOfURL: NSURL(string: urlPic)!){
                            
                            let uploadTask = profilePicRef.putData(imageData, metadata: nil){
                                (metadata, error) in
                                if error == nil{
                                    let downloadURL = metadata?.downloadURL
                                }else{
                                    print(error?.localizedDescription)
                                }
                            }
                            self.userPic.image = UIImage(data: imageData)
                        }
                    }
                    
                })
        
            
        }else {
            // No user is signed in.
        }
        }
    }
    
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.userPic.layer.cornerRadius = userPic.bounds.width/2
        self.userPic.clipsToBounds = true
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
