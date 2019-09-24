//
//  ContactCell.swift
//  CLEANER
//
//  Created by SangNX on 9/23/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts

class ContactCell: UITableViewCell {

    public static let identifer = "ContactCell"
    private var contact: CNContact!
    @IBOutlet weak var lbl_name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupCell(contact: CNContact) {
        self.contact = contact
        lbl_name.text = contact.givenName + " " + contact.familyName
    }
}

