//
//  LoginView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

struct LoginView: View {
    @StateObject var vm: LoginViewModel
    @FocusState private var focused: Bool

    var onBack: () -> Void = {}
    var onSubmit: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Button(action: onBack) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Назад")
                        .font(.system(size: 16))
                }
                .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .padding(.top, 8)

            Spacer().frame(height: 34)

            Text("Введите номер\nактивации")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.black)

            Spacer().frame(height: 10)

            Text("Мы выслали его на номер \(vm.maskedPhone)")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.45))

            Spacer().frame(height: 28)

            ZStack {
                TextField("", text: $vm.code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .focused($focused)
                    .opacity(0.01)
                    .frame(maxWidth: .infinity, minHeight: 1, maxHeight: 1)
                    .onChange(of: vm.code) {
                        vm.sanitizeCode(maxDigits: 4)
                    }

                VStack(spacing: 10) {
                    otpRow
                        .contentShape(Rectangle())
                        .onTapGesture { focused = true }

                    if vm.isInvalid {
                        Text("Неверный код")
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                    }
                }
            }
            .modifier(ShakeEffect(animatableData: vm.shakeTrigger))

            Spacer().frame(height: 22)

            Button(action: {
                if vm.verify() { onSubmit() }
            }) {
                Text("Войти в систему")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(vm.primaryButtonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(vm.primaryButtonBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!vm.canSubmit)

            Spacer().frame(height: 14)

            if vm.canResend {
                Button(action: { vm.resendCode() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 13, weight: .semibold))
                        Text("Отправить код повторно")
                            .font(.system(size: 13, weight: .regular))
                    }
                    .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Text("Отправить код повторно можно через \(vm.resendCountdownText)")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.black.opacity(0.35))
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            Spacer().frame(height: 10)

            Text(vm.resendText)
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.35))
                .frame(maxWidth: .infinity, alignment: .center)

            Spacer()
        }
        .padding(.horizontal, 20)
        .onAppear {
            focused = true
            vm.startResendCountdown(seconds: 60)
        }
        .onDisappear {
            vm.stopResendCountdown()
        }
        .onChange(of: vm.code) {
            if vm.isInvalid { vm.clearInvalid() }
        }
    }

    private var otpRow: some View {
        let chars = Array(vm.code.prefix(4)).map(String.init)
        let stroke = vm.isInvalid ? Color.red : Color.black.opacity(0.20)
        let textColor = vm.isInvalid ? Color.red : Color.black
        let dotColor = vm.isInvalid ? Color.red.opacity(0.7) : Color.black.opacity(0.45)

        return GeometryReader { geo in
            let w = geo.size.width
            let digitW = w / 4
            let lineW = digitW * 0.70

            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { i in
                    VStack(spacing: 12) {
                        ZStack {
                            Text(i < chars.count ? chars[i] : "")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundStyle(textColor)
                                .opacity(i < chars.count ? 1 : 0)

                            Circle()
                                .fill(dotColor)
                                .frame(width: 6, height: 6)
                                .opacity(i < chars.count ? 0 : 1)
                        }
                        .frame(width: digitW, height: 34, alignment: .center)

                        Rectangle()
                            .fill(stroke)
                            .frame(width: lineW, height: 1)
                    }
                    .frame(width: digitW)
                }
            }
        }
        .frame(height: 34 + 12 + 1 + 8)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
