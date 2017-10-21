//
//  FollowersCell.swift
//  Instrgram
//
//  Created by Ian Mao on 7/18/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class FollowersCell: UITableViewCell {

    @IBOutlet weak var Img: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var user : AVUser!
    
    @IBAction func followBtnClicked(_ sender: Any) {
        let title = followBtn.title(for: .normal)
        
        if title == "FOLLOW" {
            
            // guard is like assert in C
            guard user != nil else {return}
            
            AVUser.current()?.follow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followBtn.setTitle("UNFOLLOW", for: .normal)
                    self.followBtn.backgroundColor = .white
                } else {
                    print (error?.localizedDescription)
                }
            })
        } else {
            
            guard user != nil else {return}
            
            AVUser.current()?.unfollow(user.objectId!, andCallback: { (success: Bool, error: Error?) in
                if success {
                    self.followBtn.setTitle("FOLLOW", for: .normal)
                    self.followBtn.backgroundColor = .lightGray
                } else {
                    print(error?.localizedDescription)
                }
            })
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // to make profile pics round shaped
        Img.layer.cornerRadius = Img.frame.width / 2
        Img.clipsToBounds = true
        
        let width = UIScreen.main.bounds.width
        
        Img.frame = CGRect(x: 7, y: 6, width: width / (5.3 * 1.1), height: width / (5.3 * 1.1))
        usernameLabel.frame = CGRect(x: Img.frame.width + 20, y: 25, width: width / 3.2, height: 27)
        followBtn.frame = CGRect(x: width - width / 3.7 - 20, y: 25, width: width / 3.7, height: 27)
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
