//
//  Post.swift
//  JoinMe2TheParty
//
//  Created by YeouTimothy on 2016/6/30.
//  Copyright © 2016年 YeouTimothy. All rights reserved.
//

import Foundation

class Post {
    
    static let post = Post()
    
    var postId:Int?
    var context:String?
    var likeNum:Int?
    var liked:Bool?
    var uid:String?
    var activityTime:String?
    var dateArray = [String]()
    
    func saveDate(newDateArray:[String]){
        self.dateArray = newDateArray
    }
    
    func deleteAll(){
        postId = nil
        context = nil
        likeNum = nil
        liked = nil
        uid = nil
        activityTime = nil
        dateArray = []
    }
}
