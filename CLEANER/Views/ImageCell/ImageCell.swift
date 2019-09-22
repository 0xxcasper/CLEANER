//
//  ImageCell.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import Foundation
import UIKit

class ImageCell: UICollectionViewCell {
    
    var image:UIImage!{
        didSet{
            imgView.image = image
        }
    }
    
    override var isSelected: Bool {
        didSet{
            if isSelected {
                viewCheck.image = #imageLiteral(resourceName: "check")
            } else {
                viewCheck.image = nil
            }
        }
    }
    
    private let imgView: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFill
        return img
    }()
    
    var viewCheck: UIImageView = {
        let img = UIImageView()
        img.layer.cornerRadius = 10
        img.layer.borderColor = UIColor.white.cgColor
        img.layer.borderWidth = 1.8
        return img
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imgView)
        imgView.anchor(top: self.topAnchor, leading: self.leadingAnchor, bottom: self.bottomAnchor, trailing: self.trailingAnchor)
        
        addSubview(viewCheck)
        viewCheck.translatesAutoresizingMaskIntoConstraints = false
        viewCheck.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8).isActive = true
        viewCheck.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        viewCheck.constrainHeight(constant: 20)
        viewCheck.constrainWidth(constant: 20)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
