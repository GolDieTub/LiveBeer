//
//  ShopAnnotation.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Foundation
import MapKit

final class ShopAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D
    var shop: ShopPoint

    init(shop: ShopPoint) {
        self.shop = shop
        self.coordinate = shop.coordinate
    }
}
