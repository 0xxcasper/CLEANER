//
//  HomeViewController.swift
//  CLEANER
//
//  Created by admin on 28/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var lblStorge: UILabel!
    private var data = ["PHOTO", "VIDEO", "CONTACT", "LOCATION"]
    @IBOutlet weak var lblPercent: UILabel!
    private var viewControllers = [ImageViewController(), VideoViewController(), ContactViewController(), LocationViewController()]

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }

    private func setUpView() {
        self.title = "Cleaner"
        lblPercent.text = "\(UIDevice.current.usedDiskSpaceInBytes/UIDevice.current.totalDiskSpaceInBytes)%"
        lblStorge.text = "\(UIDevice.current.freeDiskSpaceInMB) MB of \(UIDevice.current.totalDiskSpaceInGB)"
        
        collectionView.registerXibCell(CleanerCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func deviceRemainingFreeSpaceInBytes() -> Int64? {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: documentDirectory), let freeSize = systemAttributes[.systemFreeSize] as? NSNumber else { return nil }
        return freeSize.int64Value
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(CleanerCollectionViewCell.self, indexPath: indexPath)
        cell.layer.cornerRadius = 10
        cell.lblTitle.text = data[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.navigationController?.pushViewController(viewControllers[indexPath.row], animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat = 2
        let widthCell: CGFloat = (collectionView.frame.width - itemPerRow*22)/itemPerRow
        return CGSize(width: widthCell, height: widthCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}
