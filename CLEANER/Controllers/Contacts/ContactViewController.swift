//
//  ContactViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts

class ContactViewController: UIViewController {
    
    @IBOutlet weak var tbView: UITableView!
    private var contacts = [CNContact]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        helperFunction()
    }
    
    func setupView() {
//        tbView.register(UINib(nibName: ContactCell.identifer, bundle: nil), forCellReuseIdentifier: ContactCell.identifer)
        tbView.delegate = self
        tbView.dataSource = self
    }
    
    func helperFunction() {
        fetchAllContact()
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.identifer, for: indexPath) as! ContactCell
//        cell.setupCell(contact: contacts[indexPath.row])
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


extension ContactViewController {
    func fetchAllContact() {
        let contactStore = CNContactStore()
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try contactStore.enumerateContacts(with: request){
                (contact, stop) in
                // Array containing all unified contacts from everywhere
                self.contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                    }
                }
                self.tbView.reloadData()
            }
        } catch {
            print("unable to fetch contacts")
        }
    }
}
