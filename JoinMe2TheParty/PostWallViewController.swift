//
//  PostWallViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/26.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class PostWallViewController: UIViewController {
    
    var postDict = [String: AnyObject]()
    var postLikeList = [String: AnyObject]()
    var commentDict = [String: AnyObject]()
    var userDict = [String: User]()
    var rowAtIndex:NSIndexPath?
    let postRef = FIRDatabase.database().reference()
    var rowAtSelect = 0
    var uid:String?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func newActivityButton(sender: AnyObject) {
        self.performSegueWithIdentifier("newActivitySegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "CellForPost")
        tableView.registerNib(UINib(nibName: "PostCommentTableViewCell",bundle: nil), forCellReuseIdentifier: "CellForComment")
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.allowsSelection = false
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if let user = FIRAuth.auth()?.currentUser {
            uid = user.uid
        }
        
        self.getPost()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPost(){
        postRef.child("Post").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            self.postDict[snapshot.value?.objectForKey("postId") as! String] = snapshot.value
            self.getUser(snapshot.value?.objectForKey("uid") as! String)
            if snapshot.value?.objectForKey("Comment") != nil{
                self.getComments(snapshot.value?.objectForKey("postId") as! String, comment: (snapshot.value?.objectForKey("Comment"))![0])
            }
            if snapshot.value?.objectForKey("whoLike") != nil{
                self.getPostWhoLike(snapshot.value?.objectForKey("postId") as! String, whoLike: snapshot.value?.objectForKey("whoLike") as! [String : Bool])
            }
        })
    }
    
    func getPostWhoLike(postId:String, whoLike: [String: Bool]){
        //        print("Herererererererer:           " + "\(whoLike)")
        if whoLike[uid!] == false{
            postLikeList.removeValueForKey(postId)
        }else{
            postLikeList[postId] = whoLike
        }
    }
    
    func getComments(postid:String, comment: AnyObject){
        commentDict[postid] = comment
        //        print(commentDict[postid])
        tableView.reloadData()
    }
    
    func getUser(uid:String){
        if userDict[uid] == nil{
            postRef.child("User").child(uid).observeEventType(.Value, withBlock: {
                snapshot in
                let user = User()
                user.name = snapshot.value?.objectForKey("userName") as? String
                user.uid = uid
                user.photoUrl = NSURL(string: (snapshot.value?.objectForKey("photoUrl") as? String)!)
                self.userDict[uid] = user
                self.tableView.reloadData()
            })
        }else{
            self.tableView.reloadData()
        }
    }
}

extension PostWallViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return postDict.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if commentDict[String(section)] == nil{
            return 1
        }else{
            return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellForPost = tableView.dequeueReusableCellWithIdentifier("CellForPost", forIndexPath: indexPath) as! PostTableViewCell
        let cellForComment = tableView.dequeueReusableCellWithIdentifier("CellForComment", forIndexPath: indexPath) as! PostCommentTableViewCell
        
        cellForPost.showCommentDelegate = self
        cellForPost.likeThisPostDelegate = self
        
        cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)

        if postDict.count == 0 {
            tableView.reloadData()
            cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
        }else{
            var likeNum = "0"
            if postLikeList[String(indexPath.section)]?.count == nil{
            }else{
                if postLikeList[String(indexPath.section)]?.objectForKey(uid) != nil{
                    cellForPost.isLiked = true
                    cellForPost.likeButtonOutlet.setImage(UIImage(named: "like-1"), forState: .Normal)
                }else{
                    cellForPost.isLiked = false
                    cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
                }
                likeNum = String(postLikeList[String(indexPath.section)]!.count!)
            }
            
            cellForPost.postId = postDict[String(indexPath.section)]?.objectForKey("postId") as? String

            cellForPost.contextLable.text = postDict[String(indexPath.section)]?.objectForKey("context") as? String
            
            cellForPost.likeNumLable.text = likeNum + " 個人喜歡"
            
                        
            if userDict.count == 0 {
                self.tableView.reloadData()
            }else{
                if postDict[String(indexPath.section)]?.objectForKey("uid") != nil{
                    let userUid = postDict[String(indexPath.section)]?.objectForKey("uid") as! String
                    if userDict[userUid] != nil{
                        let user = userDict[userUid]! as User
                        cellForPost.postNameLable.text = user.name
                        cellForPost.postUserImage.image = UIImage(data: NSData(contentsOfURL: user.photoUrl!)!)
                    }else{
                        getUser(userUid)
                    }
                }
            }
            
            if indexPath.row > 0{
                if let comment = commentDict[String(indexPath.section)]{
                    cellForComment.commentContex.text = comment.objectForKey("context") as? String
                    if userDict[comment.objectForKey("uid") as! String] == nil{
                        getUser(comment.objectForKey("uid") as! String)
                    }else{
                        let commentUser = userDict[comment.objectForKey("uid") as! String]! as User
                        cellForComment.commentNameLable.text = commentUser.name
                        cellForComment.commentImage.image = UIImage(data: NSData(contentsOfURL: commentUser.photoUrl!)!)
                        return cellForComment
                    }
                }else{
                    tableView.reloadData()
                }
            }
        }
        return cellForPost
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newActivitySegue"{
            let desVC = segue.destinationViewController as! NewActivityViewController
            desVC.postIdAtCurrent = postDict.count
        }else{
            let desVc = segue.destinationViewController as! CommentViewController
            //            print(postDict["\(rowAtSelect)"] as! [String: AnyObject])
            desVc.postDictForComment = postDict["\(rowAtSelect)"] as! [String: AnyObject]
            desVc.userDict = self.userDict
            
        }
    }
}

extension PostWallViewController:ShowCommentDelegate, LikeThisPostDelegate {
    
    func showComment(cell: PostTableViewCell) {
        rowAtSelect = (tableView.indexPathForCell(cell)?.section)!
        self.performSegueWithIdentifier("showComment", sender: nil)
    }
    
    func likeThisPost(cell: PostTableViewCell) {
        let postId = cell.postId
        if cell.isLiked == true{
            postRef.child("Post").child(postId!).child("whoLike").child(uid!).removeValue()
//            cell.isLiked = false
            self.getPostWhoLike(postId!, whoLike: [uid!: false])
        }else{
            postRef.child("Post").child(postId!).child("whoLike").setValue([uid!: true])
//            cell.isLiked = true
            self.getPostWhoLike(postId!, whoLike: [uid!: true])
        }
        if #available(iOS 9.0, *) {
            tableView.remembersLastFocusedIndexPath = true
        } else {
            // Fallback on earlier versions
        }
        tableView.reloadRowsAtIndexPaths([tableView.indexPathForCell(cell)!], withRowAnimation: .Automatic)
    }
    
}
