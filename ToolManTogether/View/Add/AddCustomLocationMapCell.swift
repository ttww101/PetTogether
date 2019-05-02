//
//  AddCustomLocationMapCell.swift
//  ToolManTogether
//
//  Created by Spoke on 2018/10/8.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import MapKit

protocol CustomLocation: AnyObject {
    func locationChange(_ coordinate: CLLocationCoordinate2D)
}

class AddCustomLocationMapCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var customMapView: MKMapView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var addressLabel: UILabel!
    
    weak var mapDelegate: CustomLocation?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        customMapView.delegate = self

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func send(_ sender: Any) {
    }
    
}

extension AddCustomLocationMapCell: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = CLLocationCoordinate2DMake(customMapView.region.center.latitude, customMapView.region.center.longitude)
        print(coordinate)
        mapDelegate?.locationChange(coordinate)
    }
}
