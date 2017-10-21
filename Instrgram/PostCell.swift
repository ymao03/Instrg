//
//  PostCell.swift
//  Instrgram
//
//  Created by Ian Mao on 8/1/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit
import AVOSCloud

class PostCell: UITableViewCell {

    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var postImg: UIImageView!
    
    @IBOutlet weak var puuidLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        let width = UIScreen.main.bounds.width
//        
//        userImg.translatesAutoresizingMaskIntoConstraints = false
//        usernameBtn.translatesAutoresizingMaskIntoConstraints = false
//        postImg.translatesAutoresizingMaskIntoConstraints = false
//        puuidLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        
//        let postWidth = width - 20
//        
//        // vertical constraints
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V: |-10-[ava(30)]-10-[pic(\(postWidth))]-10-[title]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["ava": userImg, "pic": postImg, "title": titleLabel]))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V: |-10-[username]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["username": usernameBtn]))
//        
//        // horizontal constraints
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H: |-10-[ava(30)]-10-[username]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["ava": userImg, "username": usernameBtn]))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H: |-0-[pic]-0-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["pic": postImg]))
//        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H: |-10-[title]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["title": titleLabel]))
//        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
