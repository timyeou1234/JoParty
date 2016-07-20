//
//  NewGroupViewController.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/17.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import Firebase

class NewGroupViewController: UIViewController {

    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var groupKeyTextField: UITextField!
    
    @IBAction func submitAndBackButton(sender: AnyObject) {
        if groupKeyTextField.text == ""||groupNameTextField.text == ""{
        }else{
            let dataRef = FIRDatabase.database().reference()
            let key = dataRef.child("Group").childByAutoId().key
            var postList = [String: AnyObject]()
            postList = ["groupName": groupNameTextField.text!, "groupKey": groupKeyTextField.text!]
            dataRef.child("Group").child(key).setValue(postList)
            dataRef.child("User").child(CurrentUser.user.uid!).child("group").child(key).setValue(postList)
            dataRef.child("Post").child(key)
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
