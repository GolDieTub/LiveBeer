//
//  ShopsMapView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import MapKit

struct ShopsMapView: UIViewRepresentable {
    let shops: [ShopPoint]
    @Binding var selectedShopID: ShopPoint.ID?
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mv = MKMapView()
        mv.delegate = context.coordinator
        mv.isRotateEnabled = false
        mv.isPitchEnabled = false
        mv.setRegion(region, animated: false)
        mv.addAnnotations(shops.map { ShopAnnotation(shop: $0) })
        return mv
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        context.coordinator.selectedShopID = selectedShopID
        context.coordinator.onSelect = { id in
            selectedShopID = id
            refresh(mapView: uiView, animated: true)
        }
        context.coordinator.onRegionChange = { newRegion in
            region = newRegion
        }

        if !context.coordinator.isRegionApproximatelyEqual(uiView.region, region) {
            context.coordinator.isProgrammaticRegionChange = true
            uiView.setRegion(region, animated: false)
            context.coordinator.isProgrammaticRegionChange = false
        }

        syncAnnotations(on: uiView)
        refresh(mapView: uiView, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    private func syncAnnotations(on mapView: MKMapView) {
        let existing = mapView.annotations.compactMap { $0 as? ShopAnnotation }
        let existingIDs = Set(existing.map { $0.shop.id })
        let newIDs = Set(shops.map { $0.id })

        if existingIDs != newIDs {
            mapView.removeAnnotations(existing)
            mapView.addAnnotations(shops.map { ShopAnnotation(shop: $0) })
            return
        }

        for ann in existing {
            if let updated = shops.first(where: { $0.id == ann.shop.id }) {
                ann.shop = updated
                ann.coordinate = updated.coordinate
            }
        }
    }

    private func refresh(mapView: MKMapView, animated: Bool) {
        for ann in mapView.annotations {
            guard let shopAnn = ann as? ShopAnnotation,
                  let view = mapView.view(for: ann) as? ShopAnnotationView
            else { continue }
            view.apply(shop: shopAnn.shop, isSelected: shopAnn.shop.id == selectedShopID, animated: animated)
        }
    }

    final class Coordinator: NSObject, MKMapViewDelegate {
        var selectedShopID: ShopPoint.ID?
        var onSelect: ((ShopPoint.ID?) -> Void)?
        var onRegionChange: ((MKCoordinateRegion) -> Void)?
        var isProgrammaticRegionChange = false

        func isRegionApproximatelyEqual(_ a: MKCoordinateRegion, _ b: MKCoordinateRegion) -> Bool {
            let epsCenter: CLLocationDegrees = 0.00001
            let epsSpan: CLLocationDegrees = 0.00001

            return abs(a.center.latitude - b.center.latitude) < epsCenter &&
                   abs(a.center.longitude - b.center.longitude) < epsCenter &&
                   abs(a.span.latitudeDelta - b.span.latitudeDelta) < epsSpan &&
                   abs(a.span.longitudeDelta - b.span.longitudeDelta) < epsSpan
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let ann = annotation as? ShopAnnotation else { return nil }

            let reuse = "ShopAnnotationView"
            let view: ShopAnnotationView

            if let v = mapView.dequeueReusableAnnotationView(withIdentifier: reuse) as? ShopAnnotationView {
                view = v
                view.annotation = ann
            } else {
                view = ShopAnnotationView(annotation: ann, reuseIdentifier: reuse)
            }

            view.apply(shop: ann.shop, isSelected: ann.shop.id == selectedShopID, animated: false)
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let ann = view.annotation as? ShopAnnotation else { return }

            if selectedShopID == ann.shop.id {
                onSelect?(nil)
            } else {
                onSelect?(ann.shop.id)
            }

            mapView.deselectAnnotation(ann, animated: false)
        }

        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            guard !isProgrammaticRegionChange else { return }
            onRegionChange?(mapView.region)
        }
    }
}
