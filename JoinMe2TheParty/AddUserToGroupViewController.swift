//
//  AddUserToGroupViewController.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/17.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import UIKit
import SDWebImage
import Firebase
import FBSDKCoreKit

class AddUserToGroupViewController: UIViewController {

    var count = 0
    
    var groupDetail = [String: String]()
    var myGroupArray = [AnyObject]()
    var userArray = [User]()
    let userRef = FIRDatabase.database().reference().child("User")
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUser = [User]()
    
    @IBOutlet weak var navigationBarTitle: UINavigationItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerNib(UINib(nibName: "GroupUserListTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableViewAutomaticDimension
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationBarTitle.title = groupDetail["groupName"]
        self.getUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMyGroupList(){
        userRef.child(CurrentUser.user.uid!).child("group").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            var myGroupDict = [String:AnyObject]()
            let groupName = snapshot.value?.objectForKey("groupName") as? String
            let groupKey = snapshot.value?.objectForKey("groupKey") as? String
            
            myGroupDict["groupName"] = groupName
            myGroupDict["groupKey"] = groupKey
            
            self.myGroupArray.append(myGroupDict)
        })
    }
    
    
    //MARK: DownloadUser list
    func getUser(){
        userRef.observeEventType(.ChildAdded, withBlock: {
            snapshot in
            let user = User()
            if CurrentUser.user.uid != snapshot.key{
                user.name = snapshot.value?.objectForKey("userName") as? String
                user.email = snapshot.value?.objectForKey("email") as? String
                if let photoURL = snapshot.value?.objectForKey("photoUrl") as? String{
                    user.photoUrl =  NSURL(string: photoURL)}
                
                if let groupId = snapshot.value?.objectForKey("group") as? [String:AnyObject]{
                    for (a, _) in groupId{
                        user.groupId.append(a)
                    }
                }
                
                user.uid = snapshot.key
                self.userArray.append(user)
                self.sortArray(self.userArray)
            }
        })
    }
    
    //MARK: Sort Array
    /////////////////////////////////////////////////////////////////////////////
    func sortArray(Array:[AnyObject]){
        if Array.count > 2{
            var ansArray = [User()]
            for _ in 0...Array.count - 1{
                let userHere = User()
                ansArray.append(userHere)
            }
            var position = 0
            var i = 0
            var smallerThan = 0
            while  i < Array.count {
                for y in 0...Array.count-1{
                    if (userArray[i].name) < (userArray[y].name){
                        smallerThan += 1
                    }
                }
                position = userArray.count - smallerThan - 1
                ansArray[position] = userArray[i]
                i += 1
                position = 0
                smallerThan = 0
            }
            userArray = ansArray
            var x = 0
            while x < userArray.count-1{
                if userArray[x].name == nil{
                    userArray.removeAtIndex(x)
                }else{
                    x += 1
                }
            }
            self.tableView.reloadData()
        }
    }
    
    //MARK: Search user by name
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUser = userArray.filter({
            user in
            if let thereIs = user.name?.lowercaseString.containsString(searchText.lowercaseString){
                return thereIs
            }else{
                return false
            }
        })
        tableView.reloadData()
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

extension AddUserToGroupViewController: UISearchResultsUpdating, UISearchBarDelegate{
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension AddUserToGroupViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var user = User()
        user = userArray[indexPath.row]
        if user.groupId.contains(groupDetail["groupId"]!){
            user.groupId.removeAtIndex(user.groupId.indexOf(groupDetail["groupId"]!)!)
            
            userRef.child(user.uid!).child("group").child(groupDetail["groupId"]!).setValue(nil)
        }else{
            user.groupId.append(groupDetail["groupId"]!)
            var updateList = [String:String]()
            updateList["groupName"] = groupDetail["groupName"]
            updateList["groupKey"] = groupDetail["groupKey"]
            userRef.child(user.uid!).child("group").child(groupDetail["groupId"]!).setValue(updateList)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredUser.count
        }
        return userArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! GroupUserListTableViewCell
        var user = User()
        if searchController.active && searchController.searchBar.text != "" {
            user = userArray[indexPath.row]
        } else {
            user = userArray[indexPath.row]
        }
        
        cell.accessoryType = .None
        
        if user.groupId.count > 0{
            
            if user.groupId.contains(groupDetail["groupId"]!){
                cell.accessoryType = .Checkmark
            }else{
                cell.accessoryType = .None
            }
        }

        cell.nameLable.text = user.name
        cell.selfieImageView.sd_setImageWithURL(user.photoUrl)
        return cell
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
