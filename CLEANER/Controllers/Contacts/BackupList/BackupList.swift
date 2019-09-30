//
//  BackupList.swift
//  CLEANER
//
//  Created by SangNX on 9/30/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SwiftyContacts

let Key_Backup = "Key_Backup"

class BackupList: BaseViewController {
    @IBOutlet weak var btnBackup: UIButton!
    @IBOutlet weak var tbView: UITableView!
    let defaults = UserDefaults.standard

    private var listContacts: [String:[CNContact]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDataShowTableView()
    }
    
    func setupView() {
        self.title = "Backup"
        btnBackup.layer.cornerRadius = 25
        tbView.delegate = self
        tbView.dataSource = self
        tbView.register(UINib(nibName: "BackupCell", bundle: nil), forCellReuseIdentifier: "BackupCell")
    }
    
    @IBAction func actBackup(_ sender: Any) {
        handleBackupNow()
    }
    
    func handleBackupNow() {
        var array: [String:[CNContact]]
        array = loadData() ?? [:]
        array.updateValue(fetchAllContact(), forKey: getTitleCell())
        saveData(data: array)
        getDataShowTableView()
    }
    
    func getDataShowTableView() {
        listContacts.removeAll()
        listContacts = loadData() ?? [:]
        tbView.reloadData()
    }
    

    
    func getTitleCell() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return format.string(from: date)
    }
}


extension BackupList: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(reuseIdentifier: "BackupCell", for: indexPath) as! BackupCell
        cell.setupCell(title: Array(listContacts)[indexPath.row].key, count: Array(listContacts)[indexPath.section].value.count)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            tableView.beginUpdates()
            guard let cell = tableView.cellForRow(at: indexPath) as? BackupCell else {return}
            listContacts.removeValue(forKey: cell._title)
            remove()
            saveData(data: listContacts)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ListContactsBackup()
        guard let cell = tableView.cellForRow(at: indexPath) as? BackupCell else {return}
        vc.contacts = listContacts[cell._title] ?? []
        vc._title = cell._title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
