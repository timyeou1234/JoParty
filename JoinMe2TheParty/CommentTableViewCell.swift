//
//  CommentTableViewCell.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/7/6.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit

protocol DoCommentDelegate:class {
    func doComment()
}


class CommentTableViewCell: UITableViewCell {
    
    var doCommentDelegate:DoCommentDelegate?
    
    @IBOutlet weak var postUserImage: UIImageView!
    
    @IBAction func likeButton(sender: AnyObject) {
    }
    @IBAction func joinButton(sender: AnyObject) {
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
