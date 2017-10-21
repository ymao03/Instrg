//
//  PictureCell.swift
//  Instrgram
//
//  Created by Ian Mao on 7/14/17.
//  Copyright © 2017 Ian Mao. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    @IBOutlet weak var picImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        picImg.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
}
