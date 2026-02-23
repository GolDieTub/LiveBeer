//
//  ShopPoint.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation
import CoreLocation

struct ShopPoint: Identifiable {
    let id = UUID()
    let address: String
    let phone: String
    let coordinate: CLLocationCoordinate2D
}
