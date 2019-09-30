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

enum ContactVCType: String {
    case all         = "all"
    case name        = "name"
    case phone       = "phone"
    case email       = "email"
}

class ContactViewController: BaseViewController, CNContactViewControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var tbView: UITableView!
    private var isSelect: Bool = true
    var typeVC: ContactVCType = .all

    private let contactStore = CNContactStore()
    private var isSeaching: Bool = false
    private var isSelecting: Bool = false
    //-->Base contacts
    private var contacts = [CNContact]()
    //-->TableView dont have Header
    private var show_contacts = [CNContact]()
    //-->TableView have Header
    private var listContacts: [(key: String, value: [CNContact])] = []
    //-->List contacts Delete
    private var contactsDelete = [IndexPath : CNContact]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        helperFunction()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        show_contacts.removeAll()
        listContacts.removeAll()
        contacts.removeAll()
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
        //Button
        let btn_select = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(handle_Select))
        navigationItem.rightBarButtonItems = [btn_select]

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
        self.contacts = fetchAllContact()
        switch typeVC {
        case .name:
            contacts = noInfoName(contacts: contacts)
            break
        case .email:
            contacts = noInfoEmail(contacts: contacts)
            break
        case .phone:
            contacts = noInfoPhone(contacts: contacts)
        default:
            break
        }
        createAlphabets()
    }
    
    func createAlphabets() {
        var items: [String: [CNContact]] = [:]
        show_contacts.removeAll()
        listContacts.removeAll()
        show_contacts = contacts.sorted {
            return ($0.givenName)  < ($1.givenName)
        }
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
    @IBAction func handleDeleteContacts(_ sender: Any) {
        deleteContacts()
    }
    
    @objc func handle_Select(sender: UIBarButtonItem) {
        if (sender.title == "Select") {
            sender.title = "Done"
            isSelecting = true
        } else {
            sender.title = "Select"
            isSelecting = false
            (contactsDelete.count) > 0 ? (deleteContacts()) : ()
        }
        tbView.reloadData()
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
        cell.setupCell(contact: contact, index: indexPath, isSelecting: isSelecting)
        cell.isSelectedImage = _isSelectedImage
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        (listContacts.count == 0) ? (title = "") : (title = listContacts[section].key)
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = isSeaching ? show_contacts[indexPath.row] : listContacts[indexPath.section].value[indexPath.row]
        pushtoContactVCApple(_contact: contact)
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
    
    func deleteContacts() {
        let _store = CNContactStore()
        contactsDelete.forEach { (key, value) in
            let req = CNSaveRequest()
            let mutableContact = value.mutableCopy() as! CNMutableContact
            req.delete(mutableContact)
            do{
                try _store.execute(req)
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
        self.tbView.reloadData()
    }
    
}
