//
//  JoinViewController.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/11.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import Firebase

class JoinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var postId:Int?
    var dateArray = [String]()
    var userJoinDate = [String: Bool]()
    var post = [String:AnyObject]()
    var currentUserUid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerNib(UINib(nibName: "JoinTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        if let user = FIRAuth.auth()?.currentUser {
            currentUserUid = user.uid
        }
        
        if let joinList = post["joinList"]{
            if let UserJoinDate = joinList[currentUserUid!]{
                print(UserJoinDate)
                self.userJoinDate = UserJoinDate as! [String: Bool]
            }
        }
        
        
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

extension JoinViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let ref = FIRDatabase.database().reference()
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if cell.accessoryType != .Checkmark{
                cell.accessoryType = .Checkmark
                ref.child("User").child(currentUserUid!).child("activityWillJoin").child(post["postId"] as! String).child(dateArray[indexPath.row]).setValue(true)
                ref.child("Post").child(post["postId"] as! String).child("joinList").child(currentUserUid!).child(dateArray[indexPath.row]).setValue(true)
            }else{
                cell.accessoryType = .None
                ref.child("User").child(currentUserUid!).child("activityWillJoin").child(post["postId"] as! String).child(dateArray[indexPath.row]).setValue(nil)
                
                ref.child("Post").child(post["postId"] as! String).child("joinList").child(currentUserUid!).child(dateArray[indexPath.row]).setValue(nil)
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! JoinTableViewCell
        
        cell.dateLable.text = dateArray[indexPath.row]
        if userJoinDate[dateArray[indexPath.row]] != nil{
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    
    
    
    
    
}
