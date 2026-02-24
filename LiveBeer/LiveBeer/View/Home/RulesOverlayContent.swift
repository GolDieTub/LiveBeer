//
//  RulesOverlayContent.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct RulesOverlayContent: View {
    let title: String
    let subtitle: String
    let bodyText: String

    var body: some View {
        VStack(spacing: 16) {
            RulesPlate(title: title, subtitle: subtitle, rulesBody: bodyText)
                .padding(.horizontal, 20)
        }
    }
}
