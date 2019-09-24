//
//  VideoCollectionViewCell.swift
//  CLEANER
//
//  Created by admin on 24/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit

class VideoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblSize: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewCheck: UIImageView!
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                viewCheck.image = #imageLiteral(resourceName: "check")
            } else {
                viewCheck.image = nil
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        img.layer.cornerRadius = 10
        img.clipsToBounds = true
        
        viewCheck.layer.cornerRadius = 10
        viewCheck.layer.borderColor = UIColor.white.cgColor
        viewCheck.layer.borderWidth = 1.8
    }

}
