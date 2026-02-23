//
//  WelcomeView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import Combine
import SwiftUI

struct WelcomeView: View {
    @StateObject var viewModel: WelcomeViewModel

    var body: some View {
        VStack(spacing: 0) {
            Image("WelcomeScreen")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)
                .padding(.horizontal, 0)

            Spacer().frame(height: 18)

            Text("Программа\nлояльности для\nклиентов LiveBeer")
                .font(LiveBeerTypography.welcomeTitle)
                .lineSpacing(4)
                .multilineTextAlignment(.center)
                .foregroundStyle(LiveBeerColors.textPrimary)
                .padding(.horizontal, 24)

            Spacer().frame(height: 22)

            HStack(spacing: 10) {
                Button(action: { viewModel.loginTapped() }) {
                    Text("Вход")
                        .font(.system(size: 17, weight: .semibold))
                }
                .buttonStyle(LiveBeerPrimaryButtonStyle())
                .frame(width: 153, height: 56)

                Button(action: { viewModel.registerTapped() }) {
                    Text("Регистрация")
                        .font(.system(size: 17, weight: .semibold))
                }
                .buttonStyle(LiveBeerPrimaryButtonStyle())
                .frame(width: 153, height: 56)
            }

            Spacer().frame(height: 12)

            Button(action: { viewModel.guestTapped() }) {
                Text("Войти без регистрации")
                    .font(.system(size: 15, weight: .regular))
            }
            .buttonStyle(LiveBeerSecondaryButtonStyle())
            .frame(width: 316, height: 44)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .all)
    }
}
