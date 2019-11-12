//
//  LocationCollectionViewCell.swift
//  CLEANER
//
//  Created by admin on 24/09/2019.
//  Copyright © 2019 SangNX. All rights reserved.
//

import UIKit
import MapKit

class LocationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBg.layer.cornerRadius = 10
        viewBg.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.layer.cornerRadius = 100/2
        self.mapView.clipsToBounds = true
        self.mapView.isScrollEnabled = false
    }
    
    func setupCell(key: String, region: MKCoordinateRegion) {
        lblLocation.text = key
        mapView.setRegion(region, animated: false)
        self.addShadow(ofColor: .black, radius: 5, offset: .zero, opacity: 0.3)
    }

}
