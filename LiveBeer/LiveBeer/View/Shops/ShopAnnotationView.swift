//
//  ShopAnnotationView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import UIKit
import MapKit
import SwiftUI

final class ShopAnnotationView: MKAnnotationView {
    private let imageView = UIImageView()
    private var host: UIHostingController<ShopCalloutView>?

    private let markerSize = CGSize(width: 34, height: 34)
    private let calloutWidth: CGFloat = 280
    private let calloutSpacing: CGFloat = 10

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        canShowCallout = false

        imageView.isUserInteractionEnabled = false
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)

        bounds = CGRect(origin: .zero, size: markerSize)
        imageView.frame = bounds
        centerOffset = CGPoint(x: 0, y: -markerSize.height / 2)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    func apply(shop: ShopPoint, isSelected: Bool, animated: Bool) {
        let name = isSelected ? "selectedMapDot" : "mapDot"
        let newImage = UIImage(named: name)

        if animated {
            UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve, .beginFromCurrentState, .allowUserInteraction]) {
                self.imageView.image = newImage
            }
        } else {
            imageView.image = newImage
        }

        if isSelected {
            ensureHost(shop: shop)
            updateCalloutLayout()

            guard let callout = host?.view else { return }

            if callout.isHidden {
                callout.isHidden = false
                if animated {
                    callout.alpha = 0
                    UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                        callout.alpha = 1
                    }
                } else {
                    callout.alpha = 1
                }
            } else {
                callout.alpha = 1
            }
        } else {
            guard let callout = host?.view, !callout.isHidden else { return }

            if animated {
                UIView.animate(withDuration: 0.16, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                    callout.alpha = 0
                }, completion: { _ in
                    callout.isHidden = true
                    callout.alpha = 1
                })
            } else {
                callout.isHidden = true
                callout.alpha = 1
            }
        }
    }

    private func ensureHost(shop: ShopPoint) {
        if host == nil {
            let h = UIHostingController(rootView: ShopCalloutView(address: shop.address, phone: shop.phone))
            h.view.backgroundColor = .clear
            h.view.isUserInteractionEnabled = true
            host = h
            addSubview(h.view)
        } else {
            host?.rootView = ShopCalloutView(address: shop.address, phone: shop.phone)
        }
    }

    private func updateCalloutLayout() {
        guard let host else { return }

        let fittingSize = CGSize(width: calloutWidth, height: .greatestFiniteMagnitude)
        let calloutHeight = host.sizeThatFits(in: fittingSize).height

        host.view.frame = CGRect(
            x: (markerSize.width - calloutWidth) / 2,
            y: -(calloutHeight + calloutSpacing),
            width: calloutWidth,
            height: calloutHeight
        )
    }
}
