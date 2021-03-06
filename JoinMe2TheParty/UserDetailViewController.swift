//
//  UserDetailViewController.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/29.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseStorage


class UserDetailViewController: UIViewController {
    
    
    var postArray = [AnyObject]()
    var userDict = [String: User]()
    let postRef = FIRDatabase.database().reference()
    var uid:String?
    var postLikeList = [String: AnyObject]()
    var rowAtSelect:Int?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinnerIcon: UIActivityIndicatorView!
    @IBOutlet weak var noActivityLable: UILabel!
    
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
        
        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.dataSource = self
        
        tableView.registerNib(UINib(nibName: "PostTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = false
        
        userPic.backgroundColor = UIColor.grayColor()
        if let user = FIRAuth.auth()?.currentUser {
            let name = user.displayName
            let email = user.email
            _ = user.photoURL
            self.uid = user.uid
            
            nameLable.text = name
            //            userPic.image = UIImage(data: NSData(contentsOfURL: photoUrl!)!)
            
            CurrentUser.user.name = name
            CurrentUser.user.uid = uid
            CurrentUser.user.email = email
            uid = CurrentUser.user.uid!
            
            let storage = FIRStorage.storage()
            let storageRef = storage.referenceForURL("gs://joinme2theparty.appspot.com")
            let profilePicRef = storageRef.child(user.uid + "/profile.jpg")
            
            
            profilePicRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    
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
                            
                            //MARK: Upload & Download
                            _ = profilePicRef.putData(imageData, metadata: nil){
                                (metadata, error) in
                                if error == nil{
                                    _ = metadata?.downloadURL
                                }else{
//                                    print(error?.localizedDescription)
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
    
    //////////////////////////////////////////////////////////////////////
    
    override func viewWillAppear(animated: Bool) {
        self.userPic.layer.cornerRadius = userPic.bounds.width/2
        self.userPic.clipsToBounds = true
        postArray = [AnyObject]()
        spinnerIcon.startAnimating()
        self.noActivityLable.hidden = true
        getCurrentUserPost()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Download method
    
    func getCurrentUserPost(){
        let ref = FIRDatabase.database().reference()
        if let user = FIRAuth.auth()?.currentUser {
            ref.child("User").child(user.uid).child("activityWillJoin").observeEventType(.Value, withBlock: {
                snapShot in
                
                
                if snapShot.childrenCount > UInt(0){
                    
                    if let _ = snapShot.value as? [String:AnyObject]
                    {
                        let snapDict = snapShot.value as! [String:AnyObject]
                        for (_, entry) in snapDict.enumerate(){
                            print("postId")
                            print(entry.0)
                            self.getPost(entry.0 as String)
                        }
                    }else{
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
    func getPost(postId:String){
        let ref = FIRDatabase.database().reference()
        ref.child("Post").child("\(postId)").observeEventType(.Value, withBlock: {
            snapshot in
            
            self.postArray.insert(snapshot.value as! NSDictionary, atIndex: 0)
            print("here")
            print(self.postArray)
            self.sortArray(self.postArray)
            if snapshot.value?.objectForKey("uid") != nil{
                self.getUser(snapshot.value?.objectForKey("uid") as! String)
                if snapshot.value?.objectForKey("whoLike") != nil{
                    self.getPostWhoLike(postId, whoLike: snapshot.value?.objectForKey("whoLike") as! [String : Bool])
                }
            }else{
                self.spinnerIcon.hidden = true
                self.noActivityLable.hidden = false
            }
            
        })
    }
    
    func getPostWhoLike(postId:String, whoLike: [String: Bool]){
        if let user = FIRAuth.auth()?.currentUser{
            if whoLike[user.uid] == false{
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
        }
        //        self.tableView.reloadData()
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
    //MARK:Sort array
    func sortArray(Array:[AnyObject]){
        if Array.count > 2{
            for here in postArray{
                if here.objectForKey("timeStamp") == nil{
                    return
                }
            }
            var ansArray = [AnyObject]()
            for _ in 0...Array.count - 1{
                ansArray.append(["a":"b"])
            }
            var position = 0
            var i = 0
            var smallerThan = 0
            while  i < postArray.count {
                for y in 0...postArray.count - 1{
                    
                        if (postArray[i].objectForKey("timeStamp") as! Int) > (postArray[y].objectForKey("timeStamp") as! Int){
                            smallerThan += 1
                        }
                    }
                
                position = postArray.count - smallerThan - 1
                ansArray[position] = postArray[i]
                i += 1
                position = 0
                smallerThan = 0
            }
            postArray = ansArray
        }
    }
    
    
    
    
    // MARK: - Prepare for segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let post = postArray[rowAtSelect!]
        let desVc = segue.destinationViewController as! CommentViewController
        
        desVc.postDictForComment = post as! [String: AnyObject]
        desVc.userDict = self.userDict
        desVc.post = post as! [String : AnyObject]
        desVc.isLiked = (sender as! PostTableViewCell).isLiked
        desVc.likeNum = (sender as! PostTableViewCell).likeNum
    }
    
    
}

extension UserDetailViewController:UITableViewDataSource{
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    //MARK:Cell for row at indexpath
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellForPost = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! PostTableViewCell
        if postArray.count - 1 >= indexPath.row{
            var post = postArray[indexPath.row] as! [String:AnyObject]
            print(post)
            
            
            cellForPost.likeButtonOutlet.setImage(UIImage(named: "like"), forState: .Normal)
            cellForPost.showCommentDelegate = self
            
            //////////////////////////////////////////////////////////////////////////////
            //MARK: 設定留言人數
            //////////////////////////////////////////////////////////////////////////////
            var commentNum = 0
            cellForPost.commentsNumberLable.text = "0 則留言"
            
            if post["Comment"]?.count > 0{
                commentNum = (post["Comment"]?.count)!
                cellForPost.commentsNumberLable.text = "\(commentNum) 則留言"
            }
            
            
            //          設定喜歡人數
            var likeNum = "0"
            if let _ = post["postId"] as? String{
                if postLikeList[(post["postId"] as? String)!]?.count == nil{
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
            }
            //          設定日曆圖案
            if post["activityDate"] != nil{
                cellForPost.dateButtonView.setImage(UIImage(named: "calendar-1"), forState: .Normal)
                //            print(postDict[String(indexPath.section)]?.objectForKey("activityDate"))
            }else{
                cellForPost.dateButtonView.setImage(UIImage(named: "calendar"), forState: .Normal)
                //            print(postDict[String(indexPath.section)]?.objectForKey("activityDate"))
            }
            //          設定貼文內容
            cellForPost.postId = post["postId"] as? String
            cellForPost.cellSection = indexPath.section
            
            
            
            cellForPost.contextLable.text = post["context"] as? String
            cellForPost.timOfIssueLable.text = post["issueTime"] as? String
            
            cellForPost.likeNumLable.text = likeNum + " 個人喜歡"
            
            
            
            
            if let userUid = post["uid"] as? String{
                if userDict[userUid] != nil{
                    let user = userDict[userUid]! as User
                    cellForPost.postNameLable.text = user.name
                    cellForPost.postUserImage.sd_setImageWithURL(user.photoUrl!)
                }else{
                    getUser(userUid)
                }
            }
            cellForPost.spinnerView.hidden = true
            spinnerView.hidden = true
        }
        return cellForPost
    }
    
    
    
}

extension UserDetailViewController:ShowCommentDelegate{
    func showDate(cell: PostTableViewCell){
        
    }
    
    func showComment(cell: PostTableViewCell) {
        rowAtSelect = (tableView.indexPathForCell(cell)?.row)!
        self.performSegueWithIdentifier("showComment", sender: cell)
    }
    
}




