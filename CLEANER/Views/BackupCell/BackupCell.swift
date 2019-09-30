//
//  BackupCell.swift
//  CLEANER
//
//  Created by SangNX on 9/30/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class BackupCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    var _title = ""
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setupCell(title: String, count: Int) {
        self.title.text = title
        _title = title
        lblCount.text = String(count)
    }
}
