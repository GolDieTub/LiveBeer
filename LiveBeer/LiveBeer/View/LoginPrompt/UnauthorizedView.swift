//
//  UnauthorizedView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct UnauthorizedView: View {
    let onLoginTap: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 0) {
                    Image("bg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height * 0.55, alignment: .bottom)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                        .allowsHitTesting(false)

                    Spacer()
                }

                VStack(spacing: 16) {
                    Spacer().frame(height: 40)

                    Text("Войдите в\nприложение")
                        .font(.system(size: 34, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LiveBeerColors.textPrimary)

                    Text("Чтобы копить баллы и литры, вам надо\nавторизироваться в приложении")
                        .font(.system(size: 15, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(LiveBeerColors.secondaryText)
                        .padding(.top, 4)

                    Button(action: onLoginTap) {
                        Text("Войти")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .buttonStyle(LiveBeerPrimaryButtonStyle())
                    .frame(width: 316, height: 56)
                    .padding(.top, 12)

                    Spacer()

                    Image("logInScreen")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .ignoresSafeArea(edges: .bottom)
                        .padding(.horizontal, 24)
                        .allowsHitTesting(false)
                }
                .padding(.top, 10)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .background(Color.white.ignoresSafeArea())
        }
    }
}
