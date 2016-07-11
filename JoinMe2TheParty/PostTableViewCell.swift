//
//  PostTableViewCell.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/26.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

protocol ShowCommentDelegate:class {
    func showComment(cell:PostTableViewCell)
}
protocol LikeThisPostDelegate:class {
    func likeThisPost(cell:PostTableViewCell)
}

import UIKit

class PostTableViewCell: UITableViewCell {
    
    weak var showCommentDelegate:ShowCommentDelegate?
    weak var likeThisPostDelegate:LikeThisPostDelegate?
    
    var isLiked:Bool?
    var likeNum:Int?
    var postId:String?
    var rowAtSelectIndexpath:NSIndexPath?

    @IBOutlet weak var postUserImage: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var dateButtonView: UIButton!
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBAction func likeButton(sender: AnyObject) {
        likeThisPostDelegate?.likeThisPost(self)
    }
    @IBAction func joinButton(sender: AnyObject) {
    }
    
    @IBAction func commentButton(sender: AnyObject) {
        showCommentDelegate?.showComment(self)
    }
    
    @IBAction func recommandNewTimeButton(sender: AnyObject) {
    }
    
    @IBOutlet weak var likeNumLable: UILabel!
    @IBOutlet weak var postNameLable: UILabel!
    @IBOutlet weak var timOfIssueLable: UILabel!
    @IBOutlet weak var contextLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        spinner.startAnimating()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
