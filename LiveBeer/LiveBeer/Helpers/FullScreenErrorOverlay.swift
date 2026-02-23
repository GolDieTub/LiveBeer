//
//  FullScreenErrorOverlay.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct FullScreenErrorOverlay: View {
    let error: AppOverlayError
    let onClose: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text(error.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.black)

                Text(error.message)
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.65))
                    .multilineTextAlignment(.center)

                Button(action: onClose) {
                    Text(error.buttonTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(hex: "#FFE100"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(18)
            .frame(maxWidth: 340)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 20)
        }
        .zIndex(9999)
    }
}
