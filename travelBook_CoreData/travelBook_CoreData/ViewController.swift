//
//  ViewController.swift
//  travelBook_CoreData
//
//  Created by Dilara Büker on 22.02.2024.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self 

    }

}

