//
//  HeaderDuplicateCellTableViewCell.swift
//  CLEANER
//
//  Created by SangNX on 9/28/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit

class HeaderDuplicateCellTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupView(_detail: String) {
    }
    
}
