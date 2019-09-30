//
//  ListContactsBackup.swift
//  CLEANER
//
//  Created by SangNX on 9/30/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class ListContactsBackup: BaseViewController {

    @IBOutlet weak var tbView: UITableView!
    
    @IBOutlet weak var btnBackup: UIButton!
    var contacts: [CNContact] = []
    private var listContacts: [(key: String, value: [CNContact])] = []

    var _title = "Backup"
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createAlphabets()
    }

    func setupView() {
        self.title = _title
        btnBackup.layer.cornerRadius = 25
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(UINib(nibName: "ContactCell", bundle: nil), forCellReuseIdentifier: "ContactCell")
        //Button
        let btn_delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(handle_Select))
        navigationItem.rightBarButtonItems = [btn_delete]
    }
    @objc func handle_Select(sender: UIBarButtonItem) {
        alertDelete()
    }
    
    func createAlphabets() {
        var items: [String: [CNContact]] = [:]
        listContacts.removeAll()
        for contact in contacts {
            if(items.keys.contains(String(contact.givenName.prefix(1)))) {
                items[String(contact.givenName.prefix(1))]?.append(contact)
            } else {
                var key = ""
                String(contact.givenName.prefix(1)) != "" ? (key = String(contact.givenName.prefix(1))) : (key = "#")
                if (key == "#") {
                    print("")
                }
                items.updateValue([contact], forKey: key)
            }
        }
        listContacts = items.sorted(by: { $0.0 < $1.0 })
        tbView.reloadData()
    }
    
    @IBAction func hanleBackup(_ sender: Any) {
        var contacts_backup: [CNContact] = []
        let all_contact_now = fetchAllContact()
        contacts.forEach { (contact) in
            if (!all_contact_now.contains(contact)) {
                contacts_backup.append(contact)
            }
        }
        contacts_backup.forEach { (contact) in
            _addContact(contact: contact)
        }
        Success()
    }
    
    func Success() {
        let alert = UIAlertController(title: "Success", message: "Backup successful.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertDelete() {
        let alert = UIAlertController(title: "Delete", message: "Do you want delete this backup? \n \(_title)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive, handler: { (_) in
            var _contacts = self.loadData() ?? [:]
            _contacts.removeValue(forKey: self._title)
            self.remove()
            self.saveData(data: _contacts)
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension ListContactsBackup: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return listContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listContacts[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(reuseIdentifier: ContactCell.identifer, for: indexPath) as! ContactCell
        cell.setupCell(contact: listContacts[indexPath.section].value[indexPath.row], index: indexPath, isSelecting: false)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        (listContacts.count == 0) ? (title = "") : (title = listContacts[section].key)
        return title
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = listContacts[indexPath.section].value[indexPath.row]
        pushtoContactVCApple(_contact: contact)
    }
}
