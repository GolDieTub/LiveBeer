//
//  HomeView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var newsStore: NewsFeedStore
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var vm = HomeViewModel()
    @StateObject private var session = SessionManager.shared

    private let leftPadding: CGFloat = 24
    private let rightPadding: CGFloat = 19

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 16) {
                header
                litersCard
                pointsCard
                newsHeaderRow
                newsStrip
                Spacer(minLength: 16)
            }
            .padding(.leading, leftPadding)
            .padding(.trailing, rightPadding)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .onAppear {
            vm.syncFromSession(session)
            Task { await vm.refresh() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                vm.syncFromSession(session)
                Task { await vm.refresh() }
            }
        }
        .task {
            await newsStore.ensureInitialLoaded()
        }
    }

    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.brandYellow

                Image("bg")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 76)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .opacity(1)

                Text("Привет, \(vm.displayName)!")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(height: 76)

            Button {
                router.presentOverlay(.barcode(
                    barcodeValue: vm.barcodeValue,
                    digitsText: vm.barcodeDigitsText,
                    title: vm.barcodeOverlayTitle,
                    message: vm.barcodeOverlayMessage
                ))
            } label: {
                BarcodePlate(payload: vm.barcodeValue, digitsText: vm.barcodeDigitsText)
            }
            .buttonStyle(.plain)
        }
        .background(Color.white)
        .clipShape(
            RoundedCorners(tl: 10, tr: 10, bl: 10, br: 10)
        )
        .shadow(radius: 0.6, y: 0.6)
    }

    private var litersCard: some View {
        let cardHeight: CGFloat = 164

        let topPad: CGFloat = 16
        let bottomPad: CGFloat = 18
        let betweenBlocks: CGFloat = 8

        let topLead: CGFloat = 24
        let topTrail: CGFloat = 14

        let bottomLead: CGFloat = 24
        let bottomTrail: CGFloat = 10

        let cols = 5
        let total = max(0, vm.litersGridTotal)
        let rows = max(1, Int(ceil(Double(total) / Double(cols))))

        let capSpacing: CGFloat = 10
        let topHSpacing: CGFloat = 22

        let bottomBlockMinHeight: CGFloat = 56

        let bottleBase: CGFloat = 64
        let bottleMin: CGFloat = 44

        return ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .frame(height: cardHeight)

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                let topContentW = max(0, w - topLead - topTrail)

                let topAvailH = max(
                    0,
                    h - topPad - bottomPad - betweenBlocks
                        - bottomBlockMinHeight
                )
                let capSizeH =
                    (topAvailH - capSpacing * CGFloat(max(0, rows - 1)))
                    / CGFloat(rows)

                let capSizeWMax =
                    (topContentW - topHSpacing - capSpacing
                        * CGFloat(max(0, cols - 1))) / CGFloat(cols)
                let capSize = max(20, floor(min(capSizeWMax, capSizeH)))

                let capsGridW =
                    capSize * CGFloat(cols) + capSpacing
                    * CGFloat(max(0, cols - 1))
                let topBlockH =
                    capSize * CGFloat(rows) + capSpacing
                    * CGFloat(max(0, rows - 1))

                let remainingW = max(0, topContentW - capsGridW - topHSpacing)

                let bottleTargetW = min(bottleBase, remainingW)
                let bottleTargetH = min(bottleBase * 1.35, topBlockH)

                let bottleSize = max(
                    bottleMin,
                    floor(min(bottleTargetW, bottleTargetH))
                )

                let bottleXInset = max(0, (remainingW - bottleSize) / 2)
                let bottleYInset = max(0, (topBlockH - bottleSize) / 2)

                VStack(spacing: betweenBlocks) {
                    HStack(alignment: .top, spacing: topHSpacing) {
                        CapGrid(
                            current: vm.litersGridCurrent,
                            total: vm.litersGridTotal,
                            columns: cols,
                            itemSize: capSize,
                            spacing: capSpacing,
                            activeName: "activeCup",
                            inactiveName: "inactiveCup"
                        )
                        .frame(
                            width: capsGridW,
                            height: topBlockH,
                            alignment: .topLeading
                        )

                        ZStack(alignment: .topLeading) {
                            Color.clear

                            Button {
                                vm.redeemGiftIfPossible()
                            } label: {
                                Image(vm.giftBottleAssetName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: bottleSize, height: bottleSize)
                                    .background {
                                        if vm.isLitersComplete {
                                            YellowGlow(size: 80)
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                            .disabled(!vm.isLitersComplete)
                            .padding(.leading, bottleXInset)
                            .padding(.top, bottleYInset)
                        }
                        .frame(
                            width: remainingW,
                            height: topBlockH,
                            alignment: .topLeading
                        )
                    }
                    .padding(.top, topPad)
                    .padding(.leading, topLead)
                    .padding(.trailing, topTrail)

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(vm.litersProgressText)
                                .font(.system(size: 32, weight: .heavy))
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(vm.litersTitleText)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.92))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Rectangle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: 1)
                            .frame(maxHeight: .infinity)

                        Text(vm.giftMessageText)
                            .padding(.top, 20)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.white.opacity(0.85))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.leading, bottomLead)
                    .padding(.trailing, bottomTrail)
                    .padding(.bottom, bottomPad)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }

    private var pointsCard: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black)
                .frame(height: 150)

            Image("logInScreen")
                .resizable()
                .scaledToFit()
                .frame(height: 145)
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .trailing
                )
                .clipped()
                .offset(x: -10)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                Text(vm.pointsValueText)
                    .font(.system(size: 32, weight: .heavy))
                    .monospacedDigit()
                    .foregroundStyle(.white)

                Text(vm.pointsTitleText)
                    .padding(.top, 3)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.92))

                Text(vm.pointsBodyText)
                    .padding(.top, 8)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(.white.opacity(0.80))
                    .lineSpacing(2)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 16)
            .padding(.vertical, 16)
            .padding(.trailing, 140)

            Button {
                router.presentOverlay(
                    .rules(
                        title: vm.rulesTitle,
                        subtitle: vm.rulesSubtitle,
                        bodyText: vm.rulesBody
                    )
                )
            } label: {
                Image("moreInfo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .padding(8)
            .offset(x: 10, y: -10)
        }
        .frame(height: 150)
    }

    private var newsHeaderRow: some View {
        Button {
            router.selectTab(.info)
        } label: {
            HStack {
                Text("Будь в курсе")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.primary)

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    private var newsStrip: some View {
        Group {
            let promos = InfoPromoFactory.promos()
            let news = newsStore.articles

            let showLoader = newsStore.isLoadingInitial && news.isEmpty
            let showError = (newsStore.errorText != nil) && news.isEmpty

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(promos) { a in
                        Button {
                            router.presentSheet(.infoDetail(article: a))
                        } label: {
                            NewsMiniCard(article: a)
                        }
                        .buttonStyle(.plain)
                    }

                    ForEach(news) { a in
                        Button {
                            router.presentSheet(.infoDetail(article: a))
                        } label: {
                            NewsMiniCard(article: a)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            newsStore.loadMoreIfNeeded(current: a)
                        }
                    }

                    if showLoader {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Загружаем новости…")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .frame(height: 132, alignment: .center)
                    }

                    if showError, let err = newsStore.errorText {
                        Text(err)
                            .foregroundStyle(.red)
                            .font(.system(size: 13))
                            .padding(.horizontal, 12)
                            .frame(height: 132, alignment: .center)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }
}

struct YellowGlow: View {
    var size: CGFloat = 150

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color.yellow.opacity(0.70),
                    Color.yellow.opacity(0.20),
                    Color.yellow.opacity(0.00)
                ],
                center: .center,
                startRadius: 0,
                endRadius: size * 0.45
            )
            .blur(radius: size * 0.05)

            RadialGradient(
                colors: [
                    Color.yellow.opacity(0.35),
                    Color.yellow.opacity(0.00)
                ],
                center: .center,
                startRadius: 0,
                endRadius: size * 0.75
            )
            .blur(radius: size * 0.12)
        }
        .frame(width: size, height: size)
        .compositingGroup()
        .allowsHitTesting(false)
    }
}
