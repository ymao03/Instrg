//
//  HeaderView.swift
//  Instrgram
//
//  Created by Ian Mao on 7/14/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class HeaderView: UICollectionReusableView {
    
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var webTxt: UITextView!
    @IBOutlet weak var bioTxt: UILabel!
    
    @IBOutlet weak var numOfPost: UILabel!
    @IBOutlet weak var numOfFollowers: UILabel!
    @IBOutlet weak var numOfFollowing: UILabel!
    
    @IBOutlet weak var posts: UILabel!
    @IBOutlet weak var followers: UILabel!
    @IBOutlet weak var following: UILabel!
    
    @IBOutlet weak var editProfile: UIButton!
    
    var user : AVUser?
    
    @IBAction func followBtn_clicked(_ sender: Any) {
        let title = editProfile.title(for: .normal)
        
        if title == "FOLLOW" {
            // guard is like assert in C
            guard let user = user else {return}
            
            AVUser.current()?.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.editProfile.setTitle("UNFOLLOW", for: .normal)
                } else {
                    print (error?.localizedDescription)
                }
            })
        } else {
            
            guard let user = user else {return}
            
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.editProfile.setTitle("FOLLOW", for: .normal)
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        
        userImg.frame = CGRect(x: width / 16, y: width / 16, width: width / 4, height: width / 4)
        
        numOfPost.frame = CGRect(x: width / 2.6, y: userImg.frame.origin.y, width: 50, height: 30)
        numOfFollowers.frame = CGRect(x: width / 1.7, y: userImg.frame.origin.y, width: 50, height: 30)
        numOfFollowing.frame = CGRect(x: width / 1.25, y: userImg.frame.origin.y, width: 50, height: 30)
        
        posts.center = CGPoint(x: numOfPost.center.x, y: numOfPost.center.y + 20)
        followers.center = CGPoint(x: numOfFollowers.center.x, y: numOfFollowers.center.y + 20)
        following.center = CGPoint(x: numOfFollowing.center.x, y: numOfFollowing.center.y + 20)
        
        editProfile.frame = CGRect(x: posts.frame.origin.x, y: posts.center.y + 20, width: width - posts.frame.origin.x - 15, height: 30)
        nameTxt.frame = CGRect(x: userImg.frame.origin.x, y: userImg.frame.origin.y + userImg.frame.height, width: width - 30, height: 30)
        webTxt.frame = CGRect(x: userImg.frame.origin.x - 5, y: nameTxt.frame.origin.y + 20, width: width - 30, height: 30)
        bioTxt.frame = CGRect(x: userImg.frame.origin.x, y: webTxt.frame.origin.y + 30, width: width - 30, height: 30)
    }
}
