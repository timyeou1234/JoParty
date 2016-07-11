//
//  CommentViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/7/5.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit

class CommentViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    @IBAction func sendButton(sender: AnyObject) {
        self.doComment()
    }
    
    @IBAction func dismissKeyBoard(sender: AnyObject) {
        view.endEditing(true)
        self.bottomConstraint.constant = 0
    }
    
    var isLiked:Bool?
    var likeNum:Int?
    let postRef = FIRDatabase.database().reference()
    var userDict = [String: User]()
    var postId:String?
    var postDictForComment = [String: AnyObject]()
    var commentDict = [String:AnyObject]()
    var uid:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: "CellForPost")
        tableView.registerNib(UINib(nibName: "PostCommentTableViewCell",bundle: nil), forCellReuseIdentifier: "CellForComment")
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.allowsSelection = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CommentViewController.keyboardWasShown(_:)), name: UIKeyboardWillShowNotification, object: nil)
        
        inputTextView.hidden = true
        postId = postDictForComment["postId"] as? String
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            uid = user.uid
        }
        self.getComments()
    }
    //鍵盤收合關聯功能
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.bottomConstraint.constant = keyboardFrame.size.height - 50
        })
    }
    //拿評論
    func getComments(){
        print("Here I am !!!!!!!!")
        postRef.child("Post").child((postDictForComment["postId"] as? String)!).child("Comment").observeEventType(.ChildAdded, withBlock: {
            snapshot in
            self.commentDict[snapshot.value?.objectForKey("commentId") as! String] = snapshot.value
            print("Here I am !!!!!!!!")
            self.tableView.reloadData()
            }
        )
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

extension CommentViewController: UITableViewDataSource{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentDict.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellForPost = tableView.dequeueReusableCellWithIdentifier("CellForPost", forIndexPath: indexPath) as! CommentTableViewCell
        let cellForComment = tableView.dequeueReusableCellWithIdentifier("CellForComment", forIndexPath: indexPath) as! PostCommentTableViewCell
        
        cellForPost.commentLikeThisPostDelegate = self
        
        if indexPath.row == 0{
            if isLiked!{
                cellForPost.likeButtonOutlet.setImage(UIImage(named: "like-1"), forState: .Normal)
            }else{
                cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
            }
            cellForPost.doCommentDelegate = self
            
            cellForPost.contextLable.text =  postDictForComment["context"] as? String
            cellForPost.timOfIssueLable.text = postDictForComment["issueTime"] as? String
            
            cellForPost.likeNumLable.text = String(likeNum!) + "個人說讚"
            
            let userUid = postDictForComment["uid"] as! String
            let user = userDict[userUid]! as User
            cellForPost.postNameLable.text = user.name
            cellForPost.postUserImage.image = UIImage(data: NSData(contentsOfURL: user.photoUrl!)!)
        }else{
            cellForComment.commentContex.text = commentDict["\(indexPath.row-1)"]?.objectForKey("context") as? String
            if userDict[(commentDict["\(indexPath.row-1)"]?.objectForKey("uid") as? String)!] != nil {
                let commentUser = userDict[(commentDict["\(indexPath.row-1)"]?.objectForKey("uid") as? String)!]
                cellForComment.commentNameLable.text = commentUser?.name
                cellForComment.commentImage.image = UIImage(data: NSData(contentsOfURL: (commentUser?.photoUrl)!)!)
            }else{
                let uid = (commentDict["\(indexPath.row-1)"]?.objectForKey("uid") as? String)!
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
            return cellForComment
        }
        
        
        
        return cellForPost
    }
    
}

extension CommentViewController:DoCommentDelegate, CommentLikeThisPostDelegate{
    func doComment() {
        if inputTextView.hidden{
            inputTextView.hidden = false
        }else{
            inputTextView.hidden = true
            if inputTextField != " " {
                let dataRef = FIRDatabase.database().reference()
                let comment: [String : String!] = ["context": inputTextField.text, "uid": uid, "commentId": String(commentDict.count)]
                let childUpdates = ["/Post/\(postId!)/Comment/\(commentDict.count)": comment]
                dataRef.updateChildValues(childUpdates)
                self.inputTextField.text = ""
                self.getComments()
                view.endEditing(true)
                self.bottomConstraint.constant = 0
            }
        }
    }
    func likeThisPost(cell: CommentTableViewCell) {
        if self.isLiked == true{
            cell.likeButtonOutlet.setImage(UIImage(named: "like-1"), forState: .Normal)
            cell.likeNumLable.text = String(likeNum! - 1) + "個人說讚"
            likeNum = likeNum! - 1
            postRef.child("Post").child(self.postId!).child("whoLike").child(uid!).removeValue()
            self.isLiked = false
        }else{
            cell.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
            cell.likeNumLable.text = String(likeNum! + 1) + "個人說讚"
            likeNum = likeNum! + 1
            postRef.child("Post").child(self.postId!).child("whoLike").child(uid!).setValue(true)
            self.isLiked = true
        }
        tableView.reloadRowsAtIndexPaths([tableView.indexPathForCell(cell)!], withRowAnimation: .Automatic)
    }
}









