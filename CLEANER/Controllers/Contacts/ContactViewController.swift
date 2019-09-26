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
    private var contacts = [CNContact]()
    private var show_contacts = [CNContact]()
    private var isSeaching: Bool = false
    private var listContacts: [(key: String, value: [CNContact])] = []
    private let contactStore = CNContactStore()
    private var contactsDelete = [IndexPath:CNContact]()
    private var clone_contacts = [CNContact]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        helperFunction()
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
    }
    
    func createAlphabets() {
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
        tbView.reloadData()
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
        cell.setupCell(contact: contact, index: indexPath)
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
        if (clone_contacts.contains(contact)) {return}
        clone_contacts.append(contact)
        print("sang1 \(clone_contacts.count)")
    }
    
    func didDeSelectedimageCheck(index: IndexPath, contact: CNContact) {
        if (!clone_contacts.contains(contact)) { return }
        if let index = clone_contacts.firstIndex(of: contact) { clone_contacts.remove(at: index) }
        print("sang2 \(clone_contacts.count)")
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
    
    func deleteContacts() {
        clone_contacts.forEach { (contact) in
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
}
