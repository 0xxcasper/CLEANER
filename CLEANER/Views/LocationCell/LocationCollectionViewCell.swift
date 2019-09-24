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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mapView.layer.cornerRadius = self.mapView.bounds.width/2
        self.mapView.clipsToBounds = true
        self.mapView.isScrollEnabled = false
    }

}
