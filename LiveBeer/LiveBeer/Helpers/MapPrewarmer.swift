//
//  MapPrewarmer.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import UIKit
import MapKit

final class MapPrewarmer {
    static let shared = MapPrewarmer()

    private var window: UIWindow?
    private var mapView: MKMapView?

    func prewarm(region: MKCoordinateRegion) {
        guard window == nil else { return }

        let w = UIWindow(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        w.windowLevel = .alert + 1
        w.isHidden = false

        let vc = UIViewController()
        vc.view.backgroundColor = .clear

        let mv = MKMapView(frame: vc.view.bounds)
        mv.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mv.mapType = .standard
        mv.isRotateEnabled = false
        mv.isPitchEnabled = false
        mv.setRegion(region, animated: false)

        vc.view.addSubview(mv)
        w.rootViewController = vc

        window = w
        mapView = mv

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            self?.window?.isHidden = true
            self?.window = nil
            self?.mapView = nil
        }
    }
}
