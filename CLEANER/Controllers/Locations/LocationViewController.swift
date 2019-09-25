//
//  LocationViewController.swift
//  CLEANER
//
//  Created by admin on 22/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import Photos
import MapKit

class LocationViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var data: [String: CLLocation] = [:]
    private var dataPHAssets: [String: [PHAssetCollection]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        getAllAlbums()
        setUpCollectionView()
    }
    
    private func getAllAlbums() {
        PhotosHelper.getAlbumsMoment { (PHAssetCollections) in
            PHAssetCollections.forEach({ (PHAssetCollection) in
                if let location = PHAssetCollection.approximateLocation {
                    self.getLocationNameWith(location: location, collec: PHAssetCollection)
                }
            })
        }
    }
    
    private func getLocationNameWith( location: CLLocation, collec: PHAssetCollection) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            if let city = placeMark.locality != nil ? placeMark.locality : placeMark.administrativeArea != nil ? placeMark.administrativeArea : placeMark.country {
                if Array(self.data.keys).contains(city) {
                    if !self.dataPHAssets[city]!.contains(collec) {
                        self.dataPHAssets[city]!.append(collec)
                    }
                } else {
                    self.data.updateValue(location, forKey: city)
                    self.dataPHAssets.updateValue([collec], forKey: city)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
            print("\(self.data.count)")
        })
    }
    
    private func setUpCollectionView() {
        collectionView.registerXibCell(LocationCollectionViewCell.self)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

//MARK: UICollectionViewDataSource,UICollectionViewDelegateFlowLayout 's Method

extension LocationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.keys.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(LocationCollectionViewCell.self, indexPath: indexPath)
        cell.addShadow(ofColor: .black, radius: 5, offset: .zero, opacity: 0.3)
        let key = Array(data.keys)[indexPath.row]
        let region = MKCoordinateRegion(center: data[key]!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        cell.lblLocation.text = key
        cell.mapView.setRegion(region, animated: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat = 2
        let widthCell: CGFloat = (collectionView.frame.width - (itemPerRow + 1)*16)/itemPerRow
        return CGSize(width: widthCell, height: widthCell + 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectPhotoVC = SelectPhotoViewController()
        let key = Array(data.keys)[indexPath.row]
        selectPhotoVC.isLocation = true
        selectPhotoVC.phCollections = self.dataPHAssets[key]!
        self.navigationController?.pushViewController(selectPhotoVC, animated: true)
    }
}

