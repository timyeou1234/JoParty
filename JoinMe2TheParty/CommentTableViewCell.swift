//
//  CommentTableViewCell.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/7/6.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit

protocol ShowDelegate:class {
    func showDate(cell:CommentTableViewCell)
}

protocol DoCommentDelegate:class {
    func doComment()
}

protocol CommentLikeThisPostDelegate:class {
    func likeThisPost(cell:CommentTableViewCell)
}

class CommentTableViewCell: UITableViewCell {
    
    var doCommentDelegate:DoCommentDelegate?
    var commentLikeThisPostDelegate:CommentLikeThisPostDelegate?
    var showDelegate:ShowDelegate?
    var postId:String?
    var isLiked:Bool?
    
    @IBOutlet weak var likeButtonOutlet: UIButton!
    @IBOutlet weak var postUserImage: UIImageView!
    
    @IBOutlet weak var dateButtonView: UIButton!
    @IBAction func dateButton(sender: AnyObject) {
        showDelegate?.showDate(self)
    }
    @IBAction func likeButton(sender: AnyObject) {
        commentLikeThisPostDelegate?.likeThisPost(self)
    }
    @IBAction func joinButton(sender: AnyObject) {
        showDelegate?.showDate(self)
    }
    
    @IBAction func commentButton(sender: AnyObject) {
        doCommentDelegate!.doComment()
    }
    
    @IBAction func recommandNewTimeButton(sender: AnyObject) {
        
    }
    
    @IBOutlet weak var likeNumLable: UILabel!
    @IBOutlet weak var postNameLable: UILabel!
    @IBOutlet weak var timOfIssueLable: UILabel!
    @IBOutlet weak var contextLable: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
