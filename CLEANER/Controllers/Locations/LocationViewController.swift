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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getAllAlbums()
    }

    private func getAllAlbums() {
        PhotosHelper.getAlbums { PHAssetCollections in
            PHAssetCollections.forEach({ PHAssetCollection in
                PhotosHelper.getAllPHFetchResultAssets({ PHFetchResult in
                    PHFetchResult.enumerateObjects({ (PHAsset, Int, UnsafeMutablePointer) in
                        if let location = PHAsset.location {
                            self.getLocationNameWith(location: location, completion: { (String) -> (Void) in
                                self.data.updateValue(location, forKey: String)
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData()
                                }
                            })
                        }
                    })
                })
            })
        }
    }
    
    private func getLocationNameWith( location: CLLocation, completion: @escaping ((String)->(Void))) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error -> Void in
            guard let placeMark = placemarks?.first else { return }
            let city = placeMark.locality != nil ? placeMark.locality : placeMark.administrativeArea != nil ? placeMark.administrativeArea : placeMark.country
            completion(city ?? "Other")
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
        let key = Array(data.keys)[indexPath.row]
        let region = MKCoordinateRegion(center: data[key]!.coordinate, span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1))
        cell.lblLocation.text = key
        cell.mapView.setRegion(region, animated: false)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemPerRow: CGFloat = 2
        let widthCell: CGFloat = (collectionView.frame.width - (itemPerRow + 1)*16)/itemPerRow
        return CGSize(width: widthCell, height: widthCell)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
    }
}

