//
//  PostWallViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/26.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import SDWebImage
import Firebase
import FBSDKCoreKit

class PostWallViewController: UIViewController {
    
    var postDict = [String: AnyObject]()
    var postArray = [AnyObject]()
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
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getPost(){
        postRef.child("Post").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            
            if self.postDict[snapshot.value?.objectForKey("postId") as! String] == nil{
                self.postDict[snapshot.value?.objectForKey("postId") as! String] = snapshot.value
            
                self.postArray.insert(snapshot.value!, atIndex: 0)
            }

            self.getUser(snapshot.value?.objectForKey("uid") as! String)
            if snapshot.value?.objectForKey("Comment") != nil{
                self.getComments(snapshot.value?.objectForKey("postId") as! String, comment: (snapshot.value?.objectForKey("Comment"))![0])
            }
            if snapshot.value?.objectForKey("whoLike") != nil{
                self.getPostWhoLike(snapshot.value?.objectForKey("postId") as! String, whoLike: snapshot.value?.objectForKey("whoLike") as! [String : Bool])
                //                self.getPostWhoLike(snapshot.value?.objectForKey("postId") as! String)
            }
        })
    }
    
    func getPostWhoLike(postId:String, whoLike: [String: Bool]){
            if whoLike[uid!] == false{
            if postLikeList[postId] != nil{
                var postDictHere:[String:Bool] = postLikeList[postId] as! [String:Bool]
                postDictHere.removeValueForKey(uid!)
                postLikeList[postId] = postDictHere
            }
        }else{
            if postLikeList[postId] != nil{
                var postDictHere:[String:Bool] = postLikeList[postId] as! [String:Bool]
                var uidHere:String?
                for object in whoLike{
                    uidHere = object.0
                    postDictHere[uidHere!] = true
                    postLikeList[postId] = postDictHere
                }
            }else{
                postLikeList[postId] = whoLike
            }
        }
        self.tableView.reloadData()
    }
    
    func getComments(postid:String, comment: AnyObject){
        commentDict[postid] = comment
        getUser(comment.objectForKey("uid") as! String)
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
        }
    }
}

extension PostWallViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return postArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var post = postArray[section] as! [String:AnyObject]
        if  post["Comment"] == nil{
            return 1
        }else{
            return 2
        }
    }
    
//  MARK: Cell for row
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellForPost = tableView.dequeueReusableCellWithIdentifier("CellForPost", forIndexPath: indexPath) as! PostTableViewCell
        let cellForComment = tableView.dequeueReusableCellWithIdentifier("CellForComment", forIndexPath: indexPath) as! PostCommentTableViewCell
        
        cellForPost.showCommentDelegate = self
        cellForPost.likeThisPostDelegate = self
        cellForPost.isLiked = false
        cellForPost.rowAtSelectIndexpath = indexPath
        
        var post = postArray[indexPath.section] as! [String:AnyObject]
        
        cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
        
        //          設定喜歡人數
        var likeNum = "0"
        if postLikeList[post["postId"] as! String]?.count == nil{
        }else{
            //          設定愛心圖案
            if postLikeList[post["postId"] as! String]?.objectForKey(uid) != nil{
                cellForPost.isLiked = true
                cellForPost.likeButtonOutlet.setImage(UIImage(named: "like-1"), forState: .Normal)
            }else{
                cellForPost.isLiked = false
                cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
            }
            likeNum = String(postLikeList[post["postId"] as! String]!.count!)
            cellForPost.likeNum = postLikeList[post["postId"] as! String]!.count!
        }
        //          設定日曆圖案
        if post["activityDate"] != nil{
            cellForPost.dateButtonView.setImage(UIImage(named: "calendar-1"), forState: .Normal)

        }else{
            cellForPost.dateButtonView.setImage(UIImage(named: "calendar"), forState: .Normal)

        }
        //          設定貼文內容
        cellForPost.postId = post["postId"] as? String
        cellForPost.cellSection = indexPath.section
        
        
        cellForPost.contextLable.text = post["context"] as? String
        cellForPost.timOfIssueLable.text = post["issueTime"] as? String
        
        cellForPost.likeNumLable.text = likeNum + " 個人喜歡"
        
        
        
        
        let userUid = post["uid"] as! String
        if userDict[userUid] != nil{
            let user = userDict[userUid]! as User
            cellForPost.postNameLable.text = user.name
            cellForPost.postUserImage.sd_setImageWithURL(user.photoUrl!)
        }else{
            return cellForPost
        }
        
        if indexPath.row > 0{
            if let comment = commentDict[(post["postId"] as? String)!]{
                cellForComment.commentContex.text = comment.objectForKey("context") as? String
                if userDict[comment.objectForKey("uid") as! String] == nil{
                }else{
                    let commentUser = userDict[comment.objectForKey("uid") as! String]! as User
                    cellForComment.commentNameLable.text = commentUser.name
                    cellForComment.commentImage.sd_setImageWithURL(commentUser.photoUrl!)
                    return cellForComment
                }
            }
        }
        
        cellForPost.spinnerView.hidden = true
        return cellForPost
    }

///////////////////////////////////////////////////////////////////////////////////
//MARK: PrepareForSegue
///////////////////////////////////////////////////////////////////////////////////
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "newActivitySegue"{
            
            let desVC = segue.destinationViewController as! NewActivityViewController
            desVC.postIdAtCurrent = postDict.count
        }else if segue.identifier == "showDate"{
            let post = postArray[rowAtSelect]
            if post["activityDate"] != nil{
                let desVc = segue.destinationViewController as! JoinViewController
                print(post)
                desVc.dateArray = post["activityDate"] as! [String]
                desVc.post = post as! [String : AnyObject]
            }
        }else{
            let post = postArray[rowAtSelect]
            let desVc = segue.destinationViewController as! CommentViewController

            desVc.postDictForComment = post as! [String: AnyObject]
            desVc.userDict = self.userDict
            desVc.post = post as! [String : AnyObject]
            desVc.isLiked = (sender as! PostTableViewCell).isLiked
            desVc.likeNum = (sender as! PostTableViewCell).likeNum
        }
    }
}

extension PostWallViewController:ShowCommentDelegate, LikeThisPostDelegate {

//  MARK: Perform Segue
    
    func showComment(cell: PostTableViewCell) {
        rowAtSelect = (tableView.indexPathForCell(cell)?.section)!
        self.performSegueWithIdentifier("showComment", sender: cell)
    }
    
    func showDate(cell: PostTableViewCell){
        rowAtSelect = (tableView.indexPathForCell(cell)?.section)!
        let post = postArray[rowAtSelect]
        
        if post.objectForKey("activityDate") != nil {
            self.performSegueWithIdentifier("showDate", sender: cell)
        }else{
            
        }
    }
    
///////////////////////////////////////////////////////////////////////////////////
    
    func likeThisPost(cell: PostTableViewCell) {
        let postId = cell.postId
        if cell.isLiked == true{
            cell.likeButtonOutlet.setImage(UIImage(named: "like-1"), forState: .Normal)
            postRef.child("Post").child(postId!).child("whoLike").child(uid!).removeValue()
            //            cell.isLiked = false
            cell.likeNum! -= 1
            cell.likeNumLable.text = String(cell.likeNum!) + " 個人喜歡"
            self.getPostWhoLike(postId!, whoLike: [uid!: false])
        }else{
            cell.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
            postRef.child("Post").child(postId!).child("whoLike").child(uid!).setValue(true)
            cell.likeNum! += 1
            cell.likeNumLable.text = String(cell.likeNum!) + " 個人喜歡"
            //            cell.isLiked = true
            self.getPostWhoLike(postId!, whoLike: [uid!: true])
        }
    }
}
