//
//  PostCommentTableViewCell.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/7/2.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit

class PostCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentContex: UILabel!
    @IBOutlet weak var commentNameLable: UILabel!
    @IBOutlet weak var commentImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
