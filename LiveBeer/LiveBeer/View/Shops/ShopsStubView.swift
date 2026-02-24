//
//  ShopsStubView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import MapKit

struct ShopsStubView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 25.2048, longitude: 55.2708),
        span: MKCoordinateSpan(latitudeDelta: 0.12, longitudeDelta: 0.12)
    )

    @State private var selectedShopID: ShopPoint.ID?

    private let shops: [ShopPoint] = [
        .init(address: "ул. Армейская 12", phone: "+7 924 954 03 23",
              coordinate: .init(latitude: 25.1972, longitude: 55.2744)),
        .init(address: "ул. Примерная 7", phone: "+7 999 111 22 33",
              coordinate: .init(latitude: 25.2150, longitude: 55.2550)),
        .init(address: "ул. Тестовая 1", phone: "+7 900 000 00 00",
              coordinate: .init(latitude: 25.2105, longitude: 55.2950))
    ]

    var body: some View {
        ZStack(alignment: .topLeading) {
            ShopsMapView(
                shops: shops,
                selectedShopID: $selectedShopID,
                region: $region
            )
            .ignoresSafeArea()

            Text("Наши магазины")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 14)
                .padding(.horizontal, 16)
        }
    }
}
