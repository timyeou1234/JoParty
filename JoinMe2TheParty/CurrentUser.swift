//
//  User.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/28.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import Foundation

class CurrentUser{
    
    static let user = CurrentUser()
    
    var uid:String?
    var name:String?
    var email:String?
    var selfieImage:NSData?
    
    
}
