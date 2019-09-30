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

enum DuplicateType: String {
    case name        = "name"
    case phone       = "phone"
    case email       = "email"
}
let _ContentDuplicateCell             = "ContentDuplicateCell"
let _FooterMergeCell                  = "FooterMergeCell"
let _HeaderDuplicateCellTableViewCell = "HeaderDuplicateCellTableViewCell"

class DuplicateContact: BaseViewController {
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var btnMerge: UIButton!
    private var listDuplicate: [[CNContact]] = [[]]
    private var contacts: [CNContact] = []
    private var contacts_merge: [Int :[CNContact]] = [:]
    var typeDuplicate: DuplicateType = .phone
    private var footer_detail: [Int:CNContact] = [:]
    var isSelecAll: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupData()
    }
    
    func setupData() {
        contacts.removeAll()
        contacts = self.fetchAllContact()
        switch typeDuplicate {
        case .phone:
            self.findDuplicateContacts_Phone(Contacts: contacts) { (contacts) in
                self.listDuplicate = contacts
            }
            break
        case .name:
            self.findDuplicateContacts_Name(Contacts: contacts) { (contacts) in
                self.listDuplicate = contacts
            }
            break
        default:
            self.findDuplicateContacts_Email(Contacts: contacts) { (contacts) in
                self.listDuplicate = contacts
            }
            break
        }
        tbView.reloadData()
    }
    
    func setupView() {
        self.title = "Duplicate"
        setupTableView()
        btnMerge.alpha = 0
        btnMerge.layer.cornerRadius = 25
        btnMerge.clipsToBounds = true
    }
    
    func setupTableView() {
        tbView.register(UINib(nibName: _ContentDuplicateCell, bundle: nil), forCellReuseIdentifier: _ContentDuplicateCell)
        tbView.register(UINib(nibName: _FooterMergeCell, bundle: nil), forCellReuseIdentifier: _FooterMergeCell)
        tbView.register(UINib(nibName: _HeaderDuplicateCellTableViewCell, bundle: nil), forCellReuseIdentifier: _HeaderDuplicateCellTableViewCell)
        tbView.delegate = self
        tbView.dataSource = self
    }
    
    @objc func handle_Select(sender: UIBarButtonItem) {
        if (sender.title == "Select") {
            sender.title = "Done"
            isSelecAll = true
            btnMerge.alpha = 1
        } else {
            sender.title = "Select"
            isSelecAll = false
            btnMerge.alpha = 0
        }
        tbView.reloadData()
    }
    @IBAction func handle_Merge(_ sender: Any) {
        contacts_merge.forEach { (key, value) in
            if(value.count > 0) {
                let contact_after_merge = mergeAllDuplicates(contacts: [value])
                _addContact(contact: contact_after_merge)
            }
        }
        var list_merge: [CNContact] = []
        //-->
        for (_, element) in contacts_merge.values.enumerated() {
            element.forEach { (value) in
                list_merge.append(value)
            }
        }
        //-->
        list_merge.forEach { (contact) in
            deleteContacts(contact: contact)
        }
        listDuplicate.removeAll()
        contacts_merge.removeAll()
        setupData()
        self.btnMerge.alpha = 0
    }
    
    func deleteContacts(contact: CNContact) {
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        deleteContact(Contact: mutableContact) { (result) in
            switch result{
            case .Success(response: let bool):
                if bool{
                    print("Contact Sucessfully Deleted")
                }
                break
            case .Error(error: let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
}

extension DuplicateContact: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDuplicate[section].count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return listDuplicate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (listDuplicate[indexPath.section].count == indexPath.row) {
            let footerCell = tableView.dequeueReusableCell(withIdentifier: _FooterMergeCell, for: indexPath) as! FooterMergeCell
            footerCell.setupCell(contact: footer_detail[indexPath.section])
            return footerCell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: _ContentDuplicateCell, for: indexPath) as! ContentDuplicateCell
            cell.setupCell(index: indexPath, contact: listDuplicate[indexPath.section][indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (listDuplicate[indexPath.section].count != indexPath.row) {
            let contact_ = listDuplicate[indexPath.section][indexPath.row]
            self.pushtoContactVCApple(_contact: contact_)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: _HeaderDuplicateCellTableViewCell)
        header?.backgroundColor = .white
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (listDuplicate[indexPath.section].count == indexPath.row) {
            return 106
        }
        return 65
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension DuplicateContact: ContactCellDelegate {
    func didSelectedimageCheck(index: IndexPath, contact: CNContact) {
        if (contacts_merge.keys.contains(index.section)) {
            contacts_merge[index.section]?.append(contact)
        } else {
            contacts_merge.updateValue([contact], forKey: index.section)
        }
        contacts_merge.forEach { (key, value) in
            if (value.count > 0) {
                let contact_after_merge = mergeAllDuplicates(contacts: [value])
                footer_detail.updateValue(contact_after_merge, forKey: index.section)
            }
        }
        btnMerge.alpha = 1
        tbView.reloadData()
    }
    
    func didDeSelectedimageCheck(index: IndexPath, contact: CNContact) {
        for (_, element) in contacts_merge.enumerated() {
            if let index = element.value.firstIndex(of: contact) {
                contacts_merge[element.key]?.remove(at: index)
                if (contacts_merge[element.key]?.count == 0) {
                    contacts_merge.removeValue(forKey: element.key)
                }
            }
        }
        contacts_merge.forEach { (key, value) in
            if (value.count > 0) {
                let contact_after_merge = mergeAllDuplicates(contacts: [value])
                footer_detail.updateValue(contact_after_merge, forKey: index.section)
            }
        }
        if (contacts_merge.count == 0) {
            btnMerge.alpha = 0
        }
        tbView.reloadData()
    }

}
