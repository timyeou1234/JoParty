//
//  JoinViewController.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/11.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit

class JoinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var postId:Int?
    var dateArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerNib(UINib(nibName: "JoinTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        
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
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
            if cell.accessoryType != .Checkmark{
                cell.accessoryType = .Checkmark
            }else{
                cell.accessoryType = .None
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
        
        return cell
    }
    
    
    
    
    
    
}
