//
//  ShopCalloutView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import UIKit

struct ShopCalloutView: View {
    let address: String
    let phone: String

    private let arrowWidth: CGFloat = 16
    private let arrowHeight: CGFloat = 10
    private let cornerRadius: CGFloat = 12

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text(address)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            Button {
                call(phone)
            } label: {
                Text(phone)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 16 + arrowHeight)
        .background(
            BubbleWithArrowShape(arrowWidth: arrowWidth, arrowHeight: arrowHeight, cornerRadius: cornerRadius)
                .fill(.white)
        )
        .overlay(
            BubbleWithArrowShape(arrowWidth: arrowWidth, arrowHeight: arrowHeight, cornerRadius: cornerRadius)
                .stroke(.black, lineWidth: 1)
        )
    }

    private func call(_ phone: String) {
        let digits = phone.filter { "0123456789+".contains($0) }
        let primary = URL(string: "telprompt://\(digits)")
        let fallback = URL(string: "tel://\(digits)")

        if let primary, UIApplication.shared.canOpenURL(primary) {
            UIApplication.shared.open(primary)
        } else if let fallback {
            UIApplication.shared.open(fallback)
        }
    }
}
