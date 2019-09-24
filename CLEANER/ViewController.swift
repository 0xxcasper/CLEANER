//
//  ViewController.swift
//  CLEANER
//
//  Created by SangNX on 9/22/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func image(_ sender: UIButton) {
        self.present(UINavigationController(rootViewController: LocationViewController()), animated: true, completion: nil)
    }
    
}

