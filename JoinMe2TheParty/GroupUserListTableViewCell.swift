//
//  GroupUserListTableViewCell.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/16.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import UIKit

class GroupUserListTableViewCell: UITableViewCell {
    @IBOutlet weak var selfieImageView: UIImageView!

    @IBOutlet weak var nameLable: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
