//
//  ContactViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ContactViewController: UIViewController, CNContactViewControllerDelegate {
    
    @IBOutlet weak var tbView: UITableView!
    private var contacts = [CNContact]()
    private var isSeaching: Bool = false
    private var listContacts: [(key: String, value: [CNContact])] = []
    private let contactStore = CNContactStore()
    private var contactsDelete = [IndexPath:CNContact]()


    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        helperFunction()
    }
    
    func setupView() {
        tbView.register(UINib(nibName: ContactCell.identifer, bundle: nil), forCellReuseIdentifier: ContactCell.identifer)
        tbView.delegate = self
        tbView.dataSource = self
    }
    
    func helperFunction() {
        fetchAllContact()
        createAlphabets()
    }
    
    
    func createAlphabets() {
        var items: [String: [CNContact]] = [:]
        for contact in contacts {
            if(items.keys.contains(String(contact.givenName.prefix(1)))) {
                items[String(contact.givenName.prefix(1))]?.append(contact)
            } else {
                items.updateValue([contact], forKey: String(contact.givenName.prefix(1)))
            }
        }
        listContacts = items.sorted(by: { $0.0 < $1.0 })
        tbView.reloadData()
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSeaching ? 0 : listContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSeaching ? contacts.count : listContacts[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(reuseIdentifier: ContactCell.identifer, for: indexPath) as! ContactCell
        cell.setupCell(contact: listContacts[indexPath.section].value[indexPath.row], index: indexPath)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listContacts[section].key
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var contact = listContacts[indexPath.section].value[indexPath.row]
        if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contact = try self.contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        let viewControllerforContact = CNContactViewController(for: contact)
        _ = self.navigationController?.pushViewController(viewControllerforContact, animated: true)
    }
}

extension ContactViewController: ContactCellDelegate {
    func didSelectedimageCheck(index: IndexPath, contact: CNContact) {
        <#code#>
    }
    
    func didDeSelectedimageCheck(index: IndexPath, contact: CNContact) {
        <#code#>
    }
}


extension ContactViewController {
    func fetchAllContact() {
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                self.contacts.append(contact)
//                for phoneNumber in contact.phoneNumbers {
//                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
//                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
//                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
//                    }
//                }
            }
        } catch {
            print("unable to fetch contacts")
        }
    }
}
