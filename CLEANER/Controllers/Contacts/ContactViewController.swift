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
import SwiftyContacts

class ContactViewController: UIViewController, CNContactViewControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tbView: UITableView!
    private var isSortAgain: Bool = true

    private let contactStore = CNContactStore()
    private var isSeaching: Bool = false
    //-->Base contacts
    private var contacts = [CNContact]()
    //-->TableView have Header
    private var show_contacts = [CNContact]()
    //-->TableView have Header
    private var listContacts: [(key: String, value: [CNContact])] = []
    //-->List contacts Delete
    private var contactsDelete = [IndexPath : CNContact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        helperFunction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupView() {
        addSearchBar()
        setupTableView()
    }
    
    func setupTableView() {
        tbView.register(UINib(nibName: ContactCell.identifer, bundle: nil), forCellReuseIdentifier: ContactCell.identifer)
        tbView.delegate = self
        tbView.dataSource = self
    }
    
    func addSearchBar() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.title = "Contacts"
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        searchText != "" ? (isSeaching = true) : (isSeaching = false)
        show_contacts.removeAll()
        show_contacts = contacts.filter { contact in
            return contact.givenName.lowercased().contains(searchText.lowercased()) || contact.familyName.lowercased().contains(searchText.lowercased())
        }
        tbView.reloadData()
    }
    
    func helperFunction() {
        fetchAllContact()
        createAlphabets()
        tbView.reloadData()
    }
    
    func createAlphabets() {
        if isSortAgain {
            var items: [String: [CNContact]] = [:]
            show_contacts = contacts.sorted { $0.givenName < $1.givenName }
            for contact in contacts {
                if(items.keys.contains(String(contact.givenName.prefix(1)))) {
                    items[String(contact.givenName.prefix(1))]?.append(contact)
                } else {
                    items.updateValue([contact], forKey: String(contact.givenName.prefix(1)))
                }
            }
            listContacts = items.sorted(by: { $0.0 < $1.0 })
            isSortAgain = false
        }

    }
    @IBAction func handleDeleteContacts(_ sender: Any) {
        deleteContacts()
        helperFunction()
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isSeaching ? 1 : listContacts.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSeaching ? show_contacts.count : listContacts[section].value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(reuseIdentifier: ContactCell.identifer, for: indexPath) as! ContactCell
        var contact = CNContact()
        isSeaching ? (contact = show_contacts[indexPath.row]) : (contact = listContacts[indexPath.section].value[indexPath.row])
        let _isSelectedImage = contactsDelete.keys.contains(indexPath)
        cell.setupCell(contact: contact, index: indexPath)
        cell.isSelectedImage = _isSelectedImage
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
        var contact = isSeaching ? show_contacts[indexPath.row] : listContacts[indexPath.section].value[indexPath.row]
        if !contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contact = try contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        let viewControllerforContact = CNContactViewController(for: contact)
        _ = self.navigationController?.pushViewController(viewControllerforContact, animated: true)
    }
}

extension ContactViewController: ContactCellDelegate {
    
    func didSelectedimageCheck(index: IndexPath, contact: CNContact) {
        if contactsDelete.values.contains(contact) {return}
        contactsDelete.updateValue(contact, forKey: index)
    }
    
    func didDeSelectedimageCheck(index: IndexPath, contact: CNContact) {
        if (!contactsDelete.values.contains(contact)) { return }
        for (_index, element) in contactsDelete.enumerated() {
            if (element.value == Array(contactsDelete.values)[_index]) {
                contactsDelete.removeValue(forKey: element.key)
                return
            }
        }
    }
}


extension ContactViewController {
    func fetchAllContact() {
        let _contactStore = CNContactStore()

        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try _contactStore.enumerateContacts(with: request){
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
    
    func deleteContacts() {
        contactsDelete.forEach { (key, value) in
            let req = CNSaveRequest()
            let mutableContact = value.mutableCopy() as! CNMutableContact
            req.delete(mutableContact)
            do{
                try contactStore.execute(req)
                print("Success, deleted the data: Count:  \(contacts.count)")
                if let index_contacts = contacts.firstIndex(of: value) { contacts.remove(at: index_contacts) }
                if let index_show_contacts = show_contacts.firstIndex(of: value) { show_contacts.remove(at: index_show_contacts) }
                //**--->>><<<**//
                for (_index, element) in listContacts.enumerated() {
                    for (_index_, contact) in element.value.enumerated() {
                        if (contact == value) {
                            listContacts[_index].value.remove(at: _index_)
                            if (listContacts[_index].value.count == 0) {
                                listContacts.remove(at: _index)
                            }
                            break
                        }
                    }
                }
            } catch let e{
                print("Error = \(e)")
            }
        }
        contactsDelete.removeAll()
        tbView.reloadData()
    }
    
    func aaaa() {
//        updateContact(Contact: contact) { (result) in
//            switch result{
//            case .Success(response: let bool):
//                if bool{
//                    print("Contact Sucessfully Updated")
//                }
//                break
//            case .Error(error: let error):
//                print(error.localizedDescription)
//                break
//            }
//        }
    }
}
