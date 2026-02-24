//
//  PhoneEntryView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct PhoneEntryView: View {
    @EnvironmentObject private var router: AppRouter

    @StateObject var vm: PhoneEntryViewModel
    @FocusState private var focused: Bool

    var onBack: () -> Void = {}
    var onNext: (_ phone: String, _ debugCode: String) -> Void = { _, _ in }

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

            Text("Введите ваш\nномер телефона")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.black)

            Spacer().frame(height: 10)

            Text("Мы вышлем вам проверочный код")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.45))

            Spacer().frame(height: 18)

            phoneBlock
                .modifier(ShakeEffect(animatableData: vm.shakeTrigger))

            Spacer()

            Button {
                if !vm.validate() { return }

                let normalized = AuthService.shared.normalizePhone(vm.phone)

                if !UserStore.shared.exists(phone: normalized) {
                    router.showError(
                        title: "Аккаунт не найден",
                        message: "Пользователь с таким номером не зарегистрирован. Проверьте номер или нажмите «Регистрация».",
                        buttonTitle: "Ок"
                    )
                    vm.showInvalid()
                    return
                }

                let res = AuthService.shared.requestCode(for: normalized)
                AuthService.shared.sendCodeStub(to: res.phone, code: res.code)
                onNext(res.phone, res.code)
            } label: {
                Text("Далее")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(hex: "#FFE100"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(vm.canSubmit ? 1 : 0.4)
            }
            .buttonStyle(.plain)
            .disabled(!vm.canSubmit)

            Spacer().frame(height: 14)

            HStack(spacing: 6) {
                Text("У вас нет аккаунта?")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.black.opacity(0.55))

                Button {
                    router.modalReplaceTop(with: .registration)
                } label: {
                    Text("Регистрация")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.blue)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 20)
        .onAppear {
            focused = true
            vm.reset()
        }
        .onChange(of: vm.phone) {
            vm.setPhone(vm.phone)
            if vm.isInvalid { vm.clearInvalid() }
            if vm.phoneError != nil { vm.phoneError = nil }
        }
    }

    private var phoneBlock: some View {
        let stroke = (vm.phoneError != nil || vm.isInvalid) ? Color.red : Color.black.opacity(0.08)

        return VStack(alignment: .leading, spacing: 0) {
            TextField("+7 (___) ___ __ __", text: $vm.phone)
                .keyboardType(.phonePad)
                .focused($focused)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.black.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, vm.phoneError == nil ? 8 : 0)

            if let error = vm.phoneError {
                Text(error)
                    .font(.custom("SF UI Display", size: 14).weight(.light))
                    .kerning(-0.28)
                    .monospacedDigit()
                    .foregroundStyle(Color.red)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }
}
