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
    private var oldData: [String: CLLocation] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Locations"
        data.removeAll()
        dataPHAssets.removeAll()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location) { (placemarks, error) in
            print("error-\(String(describing: error))")
            if error == nil {
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
                        if (self.data.count > 0 && self.data.keys.count > 0 && self.oldData != self.data) {
                            self.oldData = self.data
                            UIView.setAnimationsEnabled(false)
                            self.collectionView.reloadData()
                            UIView.setAnimationsEnabled(true)
                        }
                    }
                }
            }
        }
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
        if (data.count > 0 && data.keys.count > 0) {
            return data.keys.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LocationCollectionViewCell", for: indexPath) as! LocationCollectionViewCell
        if( Array(data.keys).count > 0 && Array(data.keys).count > indexPath.row) {
            let key = Array(data.keys)[indexPath.row]

            if (catchError(location: data[key]!)) {
                let region = MKCoordinateRegion(center: data[key]!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
                cell.setupCell(key: key, region: region)
            }

        }
        return cell
    }
    
    func catchError(location: CLLocation) -> Bool {
        guard (-90.0 ... 90.0).contains(location.coordinate.latitude) else {
            print("Unexpected latitude value \(location.coordinate.latitude)")
            return false
        }

        guard (-180.0 ... 180.0).contains(location.coordinate.longitude) else {
            print("Unexpected longitude value \(location.coordinate.longitude)")
            return false
        }
        return true
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
        if( Array(data.keys).count > 0 && Array(data.keys).count > indexPath.row) {
            let key = Array(data.keys)[indexPath.row]
            selectPhotoVC.isLocation = true
            selectPhotoVC.phCollections = self.dataPHAssets[key]!
            self.navigationController?.pushViewController(selectPhotoVC, animated: true)
        }
    }
}

