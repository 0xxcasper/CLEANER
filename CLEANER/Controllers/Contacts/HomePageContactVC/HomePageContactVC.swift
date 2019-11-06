//
//  HomePageContactVC.swift
//  CLEANER
//
//  Created by SangNX on 9/28/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

class HomePageContactVC: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    private var data: [[String : [String]]] = [
        ["": ["All Contacts", "Backup Contacts"]],
        ["Duplicate" : ["Name", "Phones", "Emails"]],
        ["NoInformation" : ["Name", "Phones", "Emails"]]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        collectionView.registerXibCell(AlbumCollectionViewCell.self)
        collectionView.register(SectionAlbumColViewCell.nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.reloadData()
    }
}


extension HomePageContactVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Array(data[section].values)[0].count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCollectionViewCell", for: indexPath) as! AlbumCollectionViewCell
        var amount = 0
        cell.addShadow(ofColor: .black, radius: 5, offset: .zero, opacity: 0.3)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                amount = fetchAllContact().count
                break
            default:
                amount = loadData()?.count ?? 0
            }
        case 1:
            switch indexPath.row {
            case 0:
                findDuplicateContacts_Name(Contacts: fetchAllContact()) { (contacts) in
                    amount = contacts.count
                }
                break
            case 1:
                findDuplicateContacts_Phone(Contacts: fetchAllContact()) { (contacts) in
                    amount = contacts.count
                }
                break
            default:
                findDuplicateContacts_Email(Contacts: fetchAllContact()) { (contacts) in
                    amount = contacts.count
                }
            }
        default:
            switch indexPath.row {
            case 0:
                amount = noInfoName(contacts: fetchAllContact()).count
                break
            case 1:
                amount = noInfoPhone(contacts: fetchAllContact()).count
                break
            default:
                amount = noInfoEmail(contacts: fetchAllContact()).count
            }
        }
        cell.setupCell(Array(data[indexPath.section].values)[0][indexPath.row], amount: String(amount))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionAlbum = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionAlbumColViewCell.identifier, for: indexPath) as! SectionAlbumColViewCell
        switch indexPath.section {
        case 0:
            sectionAlbum.lbl.text = ""
            break
        case 1:
            sectionAlbum.lbl.text = "Duplicate"
            break
        default:
            sectionAlbum.lbl.text = "No Informations"
        }
        return sectionAlbum
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let vc = ContactViewController()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            default:
                let vc = BackupList()
                self.navigationController?.pushViewController(vc, animated: true)
                break
            }
        case 1:
            let vc = DuplicateContact()
            switch indexPath.row {
            case 0:
                vc.typeDuplicate = DuplicateType.name
                break
            case 1:
                vc.typeDuplicate = DuplicateType.phone
                break
            default:
                vc.typeDuplicate = DuplicateType.email
                break
            }
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            let vc = ContactViewController()
            switch indexPath.row {
            case 0:
                vc.typeVC = .name
                break
            case 1:
                vc.typeVC = .phone
                break
            default:
                vc.typeVC = .email
                break
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width/2 - 16 - 8), height: 200)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
