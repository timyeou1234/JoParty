//
//  MyGroup.swift
//  JoParty
//
//  Created by YeouTimothy on 2016/7/17.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import Foundation

class MyGroup{
    
    static let myGroup = MyGroup()
    
    var groupList = [myGroup]
    var groupName:String?
    var groupKey:String?
    
    func addGroup(name: String, key: String){
        self.groupName = name
        self.groupKey = key
        self.groupList.append(MyGroup.myGroup)
    }
}
