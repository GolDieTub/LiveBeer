//
//  RegistrationView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI
import Combine

struct RegistrationView: View {
    @EnvironmentObject private var router: AppRouter

    @StateObject var vm: RegistrationViewModel
    @FocusState private var field: Field?

    @State private var isBirthPickerPresented = false
    @State private var birthTempDate = Date()

    var onBack: () -> Void = {}
    var onSubmit: () -> Void = {}

    private enum Field {
        case phone, name
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.white.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer().frame(height: headerHeight + 14)

                    fieldsBlock

                    Spacer().frame(height: 18)

                    agreementBlock

                    Spacer().frame(height: 24)

                    submitButton

                    Spacer().frame(height: 16)
                }
                .padding(.horizontal, 20)
            }

            header
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .background(Color.white)
        }
        .ignoresSafeArea(.keyboard, edges: .top)
        .onAppear { vm.reset() }
        .onChange(of: vm.phone) {
            vm.phoneError = nil
            if vm.isInvalid { vm.clearInvalid() }
        }
        .onChange(of: vm.name) {
            vm.nameError = nil
            if vm.isInvalid { vm.clearInvalid() }
        }
        .onChange(of: vm.birthDate) {
            vm.birthError = nil
            if vm.isInvalid { vm.clearInvalid() }
        }
        .onChange(of: vm.isAgreementChecked) {
            if vm.isAgreementChecked { vm.agreementError = nil }
            if vm.isInvalid { vm.clearInvalid() }
        }
    }

    private var headerHeight: CGFloat { 120 }

    private var header: some View {
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

            Spacer().frame(height: 34)

            Text("Регистрация\nаккаунта")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.black)

            Spacer().frame(height: 8)

            Text("Заполните поля данных ниже")
                .font(.system(size: 14))
                .foregroundStyle(Color.black.opacity(0.45))
        }
    }

    private var fieldsBlock: some View {
        VStack(spacing: 0) {
            fieldView(
                title: "Номер телефона",
                placeholder: "+7",
                text: $vm.phone,
                keyboard: .phonePad,
                focus: .phone,
                errorText: vm.phoneError,
                onChange: { newValue in vm.setPhone(newValue) }
            )
            .modifier(ShakeEffect(animatableData: vm.phoneShake))

            fieldView(
                title: "Ваше имя",
                placeholder: "Введите имя",
                text: $vm.name,
                keyboard: .default,
                focus: .name,
                errorText: vm.nameError,
                onChange: { _ in }
            )
            .modifier(ShakeEffect(animatableData: vm.nameShake))

            birthFieldView(errorText: vm.birthError)
                .modifier(ShakeEffect(animatableData: vm.birthShake))
        }
        .padding(.top, 18)
    }

    private var agreementBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    vm.isAgreementChecked.toggle()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.black.opacity(0.25), lineWidth: 1)
                            .frame(width: 18, height: 18)

                        if vm.isAgreementChecked {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(Color.black.opacity(0.85))
                        }
                    }
                    .frame(width: 18, height: 18)
                }
                .buttonStyle(.plain)

                Text(agreementAttributedText)
                    .font(.system(size: 12))
                    .lineSpacing(2)
                    .environment(\.openURL, OpenURLAction { url in
                        UIApplication.shared.open(url)
                        return .handled
                    })
            }

            inlineErrorText(vm.agreementError)
        }
        .modifier(ShakeEffect(animatableData: vm.agreementShake))
    }

    private var agreementAttributedText: AttributedString {
        var full = AttributedString("Я согласен с ")
        full.foregroundColor = Color.black.opacity(0.55)

        var linkPart = AttributedString("условиями обработки\nперсональных данных.")
        linkPart.foregroundColor = .blue
        linkPart.link = URL(string: "https://rickroll.it")

        full.append(linkPart)
        return full
    }

    private var submitButton: some View {
        Button {
            let ok = vm.validate()

            if let alert = vm.under18Alert {
                withAnimation(.easeInOut(duration: 0.15)) {
                    vm.birthError = vm.birthError ?? "Некорректная дата рождения"
                    vm.birthShake += 1
                    vm.isInvalid = true
                }
                router.showError(title: alert.title, message: alert.message, buttonTitle: alert.buttonTitle)
                return
            }

            if ok {
                field = nil
                onSubmit()
            }
        } label: {
            Text("Зарегистрироваться")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(hex: "#FFE100"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func birthFieldView(errorText: String?) -> some View {
        let stroke = (errorText != nil) ? Color.red : Color.black.opacity(0.08)

        return VStack(alignment: .leading, spacing: 0) {
            Text("Дата рождения")
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.45))
                .padding(.bottom, 4)

            Button {
                if let parsed = ProfileFormState.birthFormatter.date(from: vm.birthDate) {
                    birthTempDate = parsed
                } else {
                    birthTempDate = Date()
                }
                field = nil
                isBirthPickerPresented = true
            } label: {
                HStack {
                    Text(vm.birthDate.isEmpty ? "ДД.ММ.ГГГГ" : vm.birthDate)
                        .foregroundStyle(vm.birthDate.isEmpty ? Color.black.opacity(0.35) : .black)
                        .font(.system(size: 16))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.35))
                }
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.black.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isBirthPickerPresented) {
                BirthDatePickerSheet(
                    title: "Выберите дату",
                    date: $birthTempDate,
                    onCancel: {},
                    onDone: {
                        vm.birthDate = ProfileFormState.birthFormatter.string(from: birthTempDate)
                        vm.birthError = nil
                        if vm.isInvalid { vm.clearInvalid() }
                    }
                )
                .background(Color.white)
            }
            .padding(.bottom, errorText == nil ? 8 : 0)

            if let errorText {
                Text(errorText)
                    .font(.custom("SF UI Display", size: 14).weight(.light))
                    .kerning(-0.28)
                    .monospacedDigit()
                    .foregroundStyle(Color.red)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }

    private func fieldView(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType,
        focus: Field,
        errorText: String?,
        onChange: @escaping (String) -> Void
    ) -> some View {
        let stroke = (errorText != nil) ? Color.red : Color.black.opacity(0.08)

        return VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 12))
                .foregroundStyle(Color.black.opacity(0.45))
                .padding(.bottom, 4)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .focused($field, equals: focus)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .background(Color.black.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(stroke, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onChange(of: text.wrappedValue) {
                    onChange(text.wrappedValue)
                }
                .padding(.bottom, errorText == nil ? 8 : 0)

            if let errorText {
                Text(errorText)
                    .font(.custom("SF UI Display", size: 14).weight(.light))
                    .kerning(-0.28)
                    .monospacedDigit()
                    .foregroundStyle(Color.red)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }

    private func inlineErrorText(_ text: String?) -> some View {
        Text(text ?? " ")
            .font(.custom("SF UI Display", size: 14).weight(.light))
            .kerning(-0.28)
            .monospacedDigit()
            .foregroundStyle(text == nil ? Color.clear : Color.red)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 16)
    }
}
