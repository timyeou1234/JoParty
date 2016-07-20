//
//  GroupViewController.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/16.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FBSDKCoreKit

class GroupViewController: UIViewController {
    
    var count = 0
    
    var myGroupArray = [AnyObject]()
    var userArray = [User]()
    let userRef = FIRDatabase.database().reference().child("User")
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUser = [User]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

    }
    
    override func viewWillAppear(animated: Bool) {
        self.myGroupArray = [AnyObject]()
        self.tableView.reloadData()
        self.getMyGroupList()
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
            let groupId = snapshot.key
            print(groupId)
            
            myGroupDict["groupName"] = groupName
            myGroupDict["groupKey"] = groupKey
            myGroupDict["groupId"] = groupId
            
            self.myGroupArray.append(myGroupDict)
            self.sortArray(self.myGroupArray)
            
        })
    }
    
    
    //MARK: Sort Array
    /////////////////////////////////////////////////////////////////////////////
    func sortArray(Array:[AnyObject]){
        if Array.count > 2{
            let nameToCompare = myGroupArray.last?.objectForKey("groupName") as! String
            for a in 0...myGroupArray.count - 2{
                if myGroupArray[a].objectForKey("groupName") as! String == nameToCompare{
                    myGroupArray.removeLast()
                }
            }
            print(Array)
            var ansArray = [AnyObject]()
            for a in 0...myGroupArray.count - 1{
                ansArray.append(myGroupArray[a])
            }
            var position = 0
            var i = 0
            var smallerThan = 0
            while  i < myGroupArray.count {
                for y in 0...myGroupArray.count-1{
                    print(myGroupArray[i].objectForKey("groupName"))
                    if (myGroupArray[i].objectForKey("groupName") as! String) < (myGroupArray[y].objectForKey("groupName") as! String){
                        smallerThan += 1
                    }
                }
                position = myGroupArray.count - smallerThan - 1
                ansArray[position] = myGroupArray[i]
                i += 1
                position = 0
                smallerThan = 0
            }
            myGroupArray = ansArray
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
//            let categoryMatch = (scope == "All") || (candy.category == scope)
            if let thereIs = user.name?.lowercaseString.containsString(searchText.lowercaseString){
            return thereIs
            }else{
                return false
            }
        })
        tableView.reloadData()
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "groupDetail"{
            let destinationController = segue.destinationViewController as! AddUserToGroupViewController
            let groupInfo = sender as! [String: String]
            print(groupInfo)
            print(groupInfo["groupName"])
            destinationController.groupDetail = groupInfo
        }
    
    }
   

}

extension GroupViewController: UISearchResultsUpdating, UISearchBarDelegate{
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension GroupViewController:UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("groupDetail", sender: myGroupArray[indexPath.row])
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroupArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        var group = myGroupArray[indexPath.row] as? [String: AnyObject]
        
        cell.textLabel?.text = group!["groupName"] as? String
        return cell
    }
}







