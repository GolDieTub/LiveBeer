//
//  HomeOverlay.swift
//  LiveBeer
//
//  Created by  Uladzimir on 24.02.26.
//

import SwiftUI

struct HomeOverlay<Content: View>: View {
    @Binding var isPresented: Bool
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isPresented = false
                    }
                }

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                content
                    .frame(maxWidth: .infinity)

                Spacer(minLength: 0)

                YellowBottomButton(title: "Закрыть") {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isPresented = false
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 18)
            }
        }
    }
}
