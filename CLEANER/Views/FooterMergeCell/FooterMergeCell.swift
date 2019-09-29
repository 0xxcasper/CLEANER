//
//  FooterMergeCell.swift
//  CLEANER
//
//  Created by SangNX on 9/29/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class FooterMergeCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(contact: CNContact?) {
        if (contact == nil) {
            lblName.text = ""
            lblPhone.text = ""
            return
        }
        lblName.text = contact!.givenName + contact!.familyName
        var textPhone = ""
        for (_, value) in contact!.phoneNumbers.enumerated() {
            textPhone += (value.value as CNPhoneNumber).stringValue as String + " "
        }
        lblPhone.text = textPhone
    }
    
    
}
