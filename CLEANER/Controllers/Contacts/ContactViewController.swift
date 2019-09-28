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
    private var isSelect: Bool = true

    private let contactStore = CNContactStore()
    private var isSeaching: Bool = false
    private var isSelecting: Bool = false
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
        fetchAllContact()
        createAlphabets()
        self.findDuplicateContacts_Name(Contacts: contacts) { (arr_duplicateContact) in
        }
        self.findDuplicateContacts_Email(Contacts: contacts) { (arr_duplicateContact) in
        }
        self.findDuplicateContacts_Phone(Contacts: contacts) { (arr_duplicateContact) in
        }
    }
    
    func createAlphabets() {
        var items: [String: [CNContact]] = [:]
        show_contacts.removeAll()
        listContacts.removeAll()
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
            CNContactEmailAddressesKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey
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

    func findDuplicateContacts_Name(Contacts contacts : [CNContact], completionHandler : @escaping (_ result : [Array<CNContact>]) -> ()){
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
    
    func findDuplicateContacts_Email(Contacts contacts : [CNContact], completionHandler : @escaping (_ result : [Array<CNContact>]) -> ()){
        var arr_emails: [String] = []
        var contactGroupedByDuplicated : [Array<CNContact>] = [Array<CNContact>]()

        contacts.forEach { (contact) in
            for emailAddress in contact.emailAddresses {
                arr_emails.append(emailAddress.value as String)
            }
        }
        let uniqueArray = Array(Set(arr_emails))
        var contactGroupedByUnique = [Array<CNContact>]()
        
        for _email in uniqueArray {
            var group: [CNContact] = []
            contacts.forEach { (contact) in
                for emailAddress in contact.emailAddresses {
                    if (emailAddress.value as String) == _email {
                        group.append(contact)
                    }
                }
            }
            contactGroupedByUnique.append(group)
        }
        for items in contactGroupedByUnique{
            if items.count > 1 {
                contactGroupedByDuplicated.append(items)
            }
        }

        completionHandler(contactGroupedByDuplicated)
    }
    
    func findDuplicateContacts_Phone(Contacts contacts : [CNContact], completionHandler : @escaping (_ result : [Array<CNContact>]) -> ()){
        var arr_phones: [String] = []
        var contactGroupedByDuplicated : [Array<CNContact>] = [Array<CNContact>]()
        
        contacts.forEach { (contact) in
            for phone_number in contact.phoneNumbers {
                arr_phones.append((phone_number.value as CNPhoneNumber).stringValue)
            }
        }
        let uniqueArray = Array(Set(arr_phones))
        var contactGroupedByUnique = [Array<CNContact>]()

        for _phone in uniqueArray {
            var group: [CNContact] = []
            contacts.forEach { (contact) in
                for phoneNumber in contact.phoneNumbers {
                    if (phoneNumber.value as CNPhoneNumber).stringValue == _phone {
                        group.append(contact)
                    }
                }
            }
            contactGroupedByUnique.append(group)
        }
        for items in contactGroupedByUnique{
            if items.count > 1 {
                contactGroupedByDuplicated.append(items)
            }
        }
        completionHandler(contactGroupedByDuplicated)
    }
    
//    func mergeAllDuplicates() -> CNContact {
        
////        let duplicates: [Array<CNContact>] = //Array of Duplicates Contacts
//
//        for item in duplicates {
//
//            // CNCONTACT PROPERTIES
//
//            var namePrefix: [String] = [String]()
//            var givenName: [String] = [String]()
//            var middleName: [String] = [String]()
//            var familyName: [String] = [String]()
//            var previousFamilyName: [String] = [String]()
//            var nameSuffix: [String] = [String]()
//            var nickname: [String] = [String]()
//            var organizationName: [String] = [String]()
//            var departmentName: [String] = [String]()
//            var jobTitle: [String] = [String]()
//            var phoneNumbers: [CNPhoneNumber] = [CNPhoneNumber]()
//            var emailAddresses: [NSString] = [NSString]()
//            var postalAddresses: [CNPostalAddress] = [CNPostalAddress]()
//            var urlAddresses: [NSString] = [NSString]()
//
//            var contactRelations: [CNContactRelation] = [CNContactRelation]()
//            var socialProfiles: [CNSocialProfile] = [CNSocialProfile]()
//            var instantMessageAddresses: [CNInstantMessageAddress] = [CNInstantMessageAddress]()
//
//            // Filter
//            for items in item {
//                namePrefix.append(items.namePrefix)
//                givenName.append(items.givenName)
//                middleName.append(items.middleName)
//                familyName.append(items.familyName)
//                previousFamilyName.append(items.previousFamilyName)
//                nameSuffix.append(items.nameSuffix)
//                nickname.append(items.nickname)
//                organizationName.append(items.organizationName)
//                departmentName.append(items.departmentName)
//                jobTitle.append(items.jobTitle)
//
//                for number in items.phoneNumbers {
//                    phoneNumbers.append(number.value)
//                }
//                for email in items.emailAddresses {
//                    emailAddresses.append(email.value)
//                }
//                for postal in items.postalAddresses {
//                    postalAddresses.append(postal.value)
//                }
//                for url in items.urlAddresses {
//                    urlAddresses.append(url.value)
//                }
//                for relation in items.contactRelations {
//                    contactRelations.append(relation.value)
//                }
//                for social in items.socialProfiles {
//                    socialProfiles.append(social.value)
//                }
//                for message in items.instantMessageAddresses {
//                    instantMessageAddresses.append(message.value)
//                }
//
//            }
//
//            let newContact = CNMutableContact()
//            newContact.namePrefix = Array(Set(namePrefix))[0]
//            newContact.givenName = Array(Set(givenName))[0]
//            newContact.middleName = Array(Set(middleName))[0]
//            newContact.familyName = Array(Set(familyName))[0]
//            newContact.previousFamilyName = Array(Set(previousFamilyName))[0]
//            newContact.nameSuffix = Array(Set(nameSuffix))[0]
//            newContact.nickname = Array(Set(nickname))[0]
//            newContact.organizationName = Array(Set(namePrefix))[0]
//            newContact.departmentName = Array(Set(namePrefix))[0]
//            newContact.jobTitle = Array(Set(namePrefix))[0]
//            for item in Array(Set(phoneNumbers)) {
//                newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(emailAddresses)) {
//                newContact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(postalAddresses)) {
//                newContact.postalAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(urlAddresses)) {
//                newContact.urlAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(contactRelations)) {
//                newContact.contactRelations.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(socialProfiles)) {
//                newContact.socialProfiles.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//            for item in Array(Set(instantMessageAddresses)) {
//                newContact.instantMessageAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
//            }
//
//            return newContact
//
//        }
//    }
}
