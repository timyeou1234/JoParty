//
//  NewActivityViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/7/4.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase
import FirebaseStorage


class NewActivityViewController: UIViewController {
    
    var postIdAtCurrent:Int?
    var uid:String?
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var bottomLayout: NSLayoutConstraint!
    @IBOutlet weak var dateButtonView: UIButton!
    
    @IBAction func postBackButton(sender: AnyObject) {
        let dataRef = FIRDatabase.database().reference()
        let date = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日H:m"
        let dateString = dateFormatter.stringFromDate(date)
        let postList = ["context": inputTextField.text, "likeNum": "0", "uid": uid, "postId": "\(postIdAtCurrent!)", "issueTime": dateString]
        let childUpdates = ["/Post/\(postIdAtCurrent!)":postList]
        dataRef.updateChildValues(childUpdates)
        
        if Post.post.dateArray.count > 0{
            dataRef.child("Post").child(String(postIdAtCurrent!)).child("activityDate").setValue(Post.post.dateArray)
        }
        
        Post.post.deleteAll()
        navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func dismissKeyBoard(sender: AnyObject) {
        view.endEditing(true)
        self.bottomLayout.constant = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userPic.backgroundColor = UIColor.grayColor()
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            uid = user.uid
            
            userName.text = name
            CurrentUser.user.name = name
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
            
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
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.userPic.layer.cornerRadius = userPic.bounds.width/2
        self.userPic.clipsToBounds = true
        if Post.post.dateArray.count > 0{
            dateButtonView.setImage(UIImage(named: "calendar-1"), forState: .Normal)
        }else{
            dateButtonView.setImage(UIImage(named: "calendar"), forState: .Normal)
        }
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomLayout.constant = keyboardFrame.size.height - 50
        })
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
