//
//  LiveBeerApp.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import MapKit
import SwiftUI

@main
struct LiveBeerApp: App {
    init() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 25.2048,
                longitude: 55.2708
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
        )
        MapPrewarmer.shared.prewarm(region: region)
    }
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
        }
    }
}
