//
//  ShakeEffect.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct ShakeEffect: GeometryEffect {
    var travelDistance: CGFloat = 10
    var numberOfShakes: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: travelDistance * sin(animatableData * .pi * numberOfShakes),
                y: 0
            )
        )
    }
}
