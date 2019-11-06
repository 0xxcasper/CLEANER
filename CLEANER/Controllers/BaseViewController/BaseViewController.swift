//
//  BaseViewController.swift
//  CLEANER
//
//  Created by SangNX on 9/28/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func fetchAllContact() -> [CNContact] {
        let _contactStore = CNContactStore()
        var contacts: [CNContact] = []
        let keys = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactImageDataAvailableKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactDepartmentNameKey,
            CNContactJobTitleKey,
            ] as [Any]
        let request = CNContactFetchRequest(keysToFetch: keys as! [CNKeyDescriptor])
        do {
            try _contactStore.enumerateContacts(with: request){ (contact, stop) in
                contacts.append(contact)
                for phoneNumber in contact.phoneNumbers {
                    if let number = phoneNumber.value as? CNPhoneNumber, let label = phoneNumber.label {
                        let localizedLabel = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                        print("\(contact.givenName) \(contact.familyName) tel:\(localizedLabel) -- \(number.stringValue), email: \(contact.emailAddresses)")
                    }
                }
            }
        } catch {
            print("unable to fetch contacts")
        }
        return contacts
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
    
    func mergeAllDuplicates(contacts : [[CNContact]]) -> CNContact {
        let duplicates: [Array<CNContact>] = contacts
        let newContact = CNMutableContact()

        for item in duplicates {
            
            var namePrefix: [String] = [String]()
            var givenName: [String] = [String]()
            var middleName: [String] = [String]()
            var familyName: [String] = [String]()
            var nickname: [String] = [String]()
            var phoneNumbers: [CNPhoneNumber] = [CNPhoneNumber]()
            var emailAddresses: [NSString] = [NSString]()            
            // Filter
            for items in item {
                namePrefix.append(items.namePrefix)
                givenName.append(items.givenName)
                middleName.append(items.middleName)
                familyName.append(items.familyName)
                nickname.append(items.nickname)

                for number in items.phoneNumbers {
                    phoneNumbers.append(number.value)
                }
                for email in items.emailAddresses {
                    emailAddresses.append(email.value)
                }
                
            }
            newContact.namePrefix = Array(Set(namePrefix))[0]
            newContact.givenName = Array(Set(givenName))[0]
            newContact.middleName = Array(Set(middleName))[0]
            newContact.familyName = Array(Set(familyName))[0]
            newContact.nickname = Array(Set(nickname))[0]

            for item in Array(Set(phoneNumbers)) {
                newContact.phoneNumbers.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
            for item in Array(Set(emailAddresses)) {
                newContact.emailAddresses.append(CNLabeledValue(label: CNLabelHome, value: item))
            }
        }
        return newContact
    }
    
    func _addContact(contact: CNContact) {
        let mutableContact = contact.mutableCopy() as! CNMutableContact
        addContact(Contact: mutableContact) { (result) in
            switch result{
            case .Success(response: let bool):
                if bool{
                    print("Contact Sucessfully Added")
                }
                break
            case .Error(error: let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func noInfoName(contacts: [CNContact]) -> [CNContact] {
        let _contacts = contacts.filter { $0.givenName == "" &&  $0.familyName == "" }
        return _contacts
    }
    
    func noInfoPhone(contacts: [CNContact]) -> [CNContact] {
        let _contacts = contacts.filter { $0.phoneNumbers.count == 0 }
        return _contacts
    }
    
    func noInfoEmail(contacts: [CNContact]) -> [CNContact] {
        var _contact: [CNContact] = []
        for (_, value) in contacts.enumerated() {
            value.emailAddresses.forEach { (email) in
                if((email.value as String) == "") {
                    _contact.append(value)
                    return
                }
            }
        }
        return _contact
    }
    
    func saveData(data: [String:[CNContact]]) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: Key_Backup)
        } catch {
            print("Error")
        }
    }
    
    func loadData() -> [String:[CNContact]]? {
        if let data = UserDefaults.standard.data(forKey: Key_Backup) {
            return try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String:[CNContact]]
        } else {
            return nil
        }
    }
    func remove() {
        UserDefaults.standard.removeObject(forKey: Key_Backup)
    }
    
    func pushtoContactVCApple(_contact: CNContact) {
        let _contactStore = CNContactStore()
        var contact = _contact

        if !_contact.areKeysAvailable([CNContactViewController.descriptorForRequiredKeys()]) {
            do {
                contact = try _contactStore.unifiedContact(withIdentifier: contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            }
            catch { }
        }
        let viewControllerforContact = CNContactViewController(for: contact)
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
//            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
//            statusBar?.backgroundColor = UIColor(displayP3Red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
//            for view in self.navigationController?.navigationBar.subviews ?? [] {
//                view.tintColor = UIColor.white
//                view.backgroundColor = UIColor(displayP3Red: 21/255, green: 101/255, blue: 192/255, alpha: 1)
//            }
//        })
        self.navigationController?.pushViewController(viewControllerforContact, animated: true)
    }
}
