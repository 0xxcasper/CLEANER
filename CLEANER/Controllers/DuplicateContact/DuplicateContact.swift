//
//  DuplicateContact.swift
//  CLEANER
//
//  Created by SangNX on 9/28/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class DuplicateContact: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.findDuplicateContacts(Contacts: contacts) { (arr_duplicateContact) in
//            print("\(arr_duplicateContact)")
//        }
    }
    
    
    func findDuplicateContacts(Contacts contacts : [CNContact], completionHandler : @escaping (_ result : [Array<CNContact>]) -> ()){
        let arrfullNames : [String?] = contacts.map{CNContactFormatter.string(from: $0, style: .fullName)}
        var contactGroupedByDuplicated : [Array<CNContact>] = [Array<CNContact>]()
        if let fullNames : [String] = arrfullNames as? [String]{
            let uniqueArray = Array(Set(fullNames))
            var contactGroupedByUnique = [Array<CNContact>]()
            for fullName in uniqueArray {
                let group = contacts.filter {
                    CNContactFormatter.string(from: $0, style: .fullName) == fullName
                }
                contactGroupedByUnique.append(group)
            }
            for items in contactGroupedByUnique{
                if items.count > 1 {
                    contactGroupedByDuplicated.append(items)
                }
            }
        }
        completionHandler(contactGroupedByDuplicated)
    }

    
}
