//
//  ContactCell.swift
//  CLEANER
//
//  Created by SangNX on 9/23/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts

protocol ContactCellDelegate: class {
    func didSelectedimageCheck(index: IndexPath, contact: CNContact)
    func didDeSelectedimageCheck(index: IndexPath, contact: CNContact)
}

class ContactCell: UITableViewCell {

    public static let identifer = "ContactCell"
    private var contact: CNContact!
    private var index: IndexPath!
    @IBOutlet weak var lbl_name: UILabel!
    @IBOutlet weak var leading_imageAvt: NSLayoutConstraint!
    weak var delegate: ContactCellDelegate?

    @IBOutlet weak var imageCheck: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    var isSelectedImage: Bool = false {
        didSet{
            if isSelectedImage {
                imageCheck.image = #imageLiteral(resourceName: "check")
                delegate?.didSelectedimageCheck(index: self.index, contact: self.contact)
            } else {
                imageCheck.image = nil
                delegate?.didDeSelectedimageCheck(index: self.index, contact: self.contact)
            }
        }
    }
    
    func setupCell(contact: CNContact, index: IndexPath) {
        self.index = index
        self.contact = contact
        lbl_name.text = contact.givenName + " " + contact.familyName
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactCell.onTapImageCheck))
        imageCheck.isUserInteractionEnabled = true
        imageCheck.addGestureRecognizer(tapRecognizer)
        
        //--->
        imageCheck.layer.cornerRadius = 10
        imageCheck.layer.borderColor = UIColor.gray.cgColor
        imageCheck.layer.borderWidth = 1.8
    }
    
    @objc func onTapImageCheck() {
        isSelectedImage = !isSelectedImage
    }
}

