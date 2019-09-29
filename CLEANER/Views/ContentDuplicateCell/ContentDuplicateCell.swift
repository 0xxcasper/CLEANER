//
//  ContentDuplicateCell.swift
//  CLEANER
//
//  Created by SangNX on 9/28/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class ContentDuplicateCell: UITableViewCell {

    @IBOutlet weak var imageCheck: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    
    private var contact: CNContact!
    private var index: IndexPath!
    weak var delegate: ContactCellDelegate?
    
    @IBOutlet weak var viewcontainer: UIView!
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
    
    func setupCell(index: IndexPath, contact: CNContact) {
        var _detail = ""
        for number in contact.phoneNumbers {
            if((number.value as CNPhoneNumber).stringValue != "") {
                _detail = (number.value as CNPhoneNumber).stringValue
            }
        }
        lblName.text = contact.givenName + contact.familyName
        lblDetail.text = _detail
        self.index = index
        self.contact = contact
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ContactCell.onTapImageCheck))
        viewcontainer.isUserInteractionEnabled = true
        viewcontainer.addGestureRecognizer(tapRecognizer)
        //--->
        imageCheck.layer.cornerRadius = 10
        imageCheck.layer.borderColor = UIColor.gray.cgColor
        imageCheck.layer.borderWidth = 1.8
    }

    @objc func onTapImageCheck() {
        isSelectedImage = !isSelectedImage
    }
    
}
