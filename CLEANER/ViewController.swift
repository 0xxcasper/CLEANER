//
//  ViewController.swift
//  CLEANER
//
//  Created by SangNX on 9/22/19.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import MapKit
import Photos

class ViewController: UIViewController {

    private var data: [String: CLLocation] = [:]
    private var dataPHAssets: [String: [PHCollection]] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotosHelper.getAlbumsMoment { (PHAssetCollections) in
            PHAssetCollections.forEach({ (PHAssetCollection) in
                if let location = PHAssetCollection.approximateLocation {
                    self.getLocationNameWith(location: location, collec: PHAssetCollection)
                }
            })
        }
    }
    
    private func getLocationNameWith( location: CLLocation, collec: PHCollection) {
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
            }
        })
    }

    @IBAction func image(_ sender: UIButton) {
        self.present(UINavigationController(rootViewController: LocationViewController()), animated: true, completion: nil)
    }
    
}

