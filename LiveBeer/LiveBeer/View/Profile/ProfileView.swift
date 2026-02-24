//
//  ProfileView.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var router: AppRouter
    @StateObject private var session = SessionManager.shared
    @StateObject private var userStore = UserStore.shared
    @StateObject private var form = ProfileFormState()

    @State private var smsEnabled: Bool = true
    @State private var originalUser: User? = nil

    @State private var isBirthPickerPresented = false
    @State private var birthTempDate = Date()

    private var isLoggedIn: Bool { session.isAuthenticated }
    private var phone: String { session.currentUserPhone ?? "" }
    private var hasChanges: Bool { form.hasChanges(comparedTo: originalUser) }

    var body: some View {
        ZStack(alignment: .top) {
            Image("bg")
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipped()
                .ignoresSafeArea()

            if isLoggedIn {
                loggedInView
            } else {
                UnauthorizedView(onLoginTap: { router.presentRoot(.welcome) })
            }
        }
        .onAppear { loadUser() }
        .onChange(of: session.currentUserPhone) { loadUser() }
        .onChange(of: form.name) { form.onNameChanged() }
        .onChange(of: form.birthDateString) { form.onBirthChanged() }
        .sheet(isPresented: $isBirthPickerPresented) {
            BirthDatePickerSheet(
                title: "Выберите дату",
                date: $birthTempDate,
                onCancel: {},
                onDone: { form.setBirth(from: birthTempDate) }
            )
        }
    }

    private var loggedInView: some View {
        VStack(spacing: 0) {
            headerView

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    nameField
                        .modifier(ShakeEffect(animatableData: form.nameShake))

                    birthField
                        .modifier(ShakeEffect(animatableData: form.birthShake))

                    phoneField(title: "Номер телефона", value: phone)

                    supportLine

                    Divider()
                        .padding(.vertical, 8)

                    HStack {
                        Text("Смс-уведомления")
                            .font(.system(size: 16, weight: .medium))
                        Spacer()
                        Toggle("", isOn: $smsEnabled)
                            .labelsHidden()
                    }
                    .padding(.vertical, 6)

                    Button(role: .destructive) {
                        askDelete()
                    } label: {
                        Text("Удалить аккаунт")
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.top, 6)

                    Spacer().frame(height: 18)

                    Button {
                        guard let originalUser else { return }
                        if form.validate(router: router) {
                            let updated = form.makeUpdatedUser(
                                from: originalUser
                            )
                            userStore.upsert(updated)
                            self.originalUser = updated
                        }
                    } label: {
                        Text("Сохранить")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(hex: "#FFE100"))
                            .foregroundStyle(.black)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 14,
                                    style: .continuous
                                )
                            )
                            .opacity(hasChanges ? 1 : 0.45)
                    }
                    .disabled(!hasChanges)

                    Text("Версия приложения 1.0.7")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 24)
            }
        }
        .padding(.top, 18)
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            Text("Профиль")
                .font(.system(size: 28, weight: .bold))

            Spacer()

            if isLoggedIn {
                Button {
                    askLogout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    private var supportLine: some View {
        Text(supportAttributedText)
            .font(.system(size: 13))
            .lineSpacing(2)
            .environment(\.openURL, OpenURLAction { url in
                UIApplication.shared.open(url)
                return .handled
            })
    }

    private var supportAttributedText: AttributedString {
        var full = AttributedString("Если вы хотите изменить номер телефона, то обратитесь в нашу ")
        full.foregroundColor = Color.secondary

        var linkPart = AttributedString("тех.поддержку")
        linkPart.foregroundColor = .blue
        linkPart.link = URL(string: "https://rickroll.it")

        full.append(linkPart)
        return full
    }

    private var nameField: some View {
        let stroke =
            (form.nameError != nil) ? Color.red : Color.black.opacity(0.12)

        return VStack(alignment: .leading, spacing: 0) {
            Text("Ваше имя")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

            TextField("", text: $form.name)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(stroke, lineWidth: 1)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(Color.white)
                        )
                )
                .padding(.bottom, form.nameError == nil ? 8 : 0)

            if let err = form.nameError {
                Text(err)
                    .font(.custom("SF UI Display", size: 14).weight(.light))
                    .kerning(-0.28)
                    .monospacedDigit()
                    .foregroundStyle(Color.red)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }

    private var birthField: some View {
        let stroke =
            (form.birthError != nil) ? Color.red : Color.black.opacity(0.12)

        return VStack(alignment: .leading, spacing: 0) {
            Text("Дата рождения")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .padding(.bottom, 4)

            Button {
                birthTempDate = form.parseBirthOrNow()
                isBirthPickerPresented = true
            } label: {
                HStack {
                    Text(
                        form.birthDateString.isEmpty
                            ? "ДД.ММ.ГГГГ" : form.birthDateString
                    )
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(
                        form.birthDateString.isEmpty
                            ? Color.black.opacity(0.35) : .primary
                    )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.35))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(stroke, lineWidth: 1)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 12,
                                style: .continuous
                            )
                            .fill(Color.white)
                        )
                )
            }
            .buttonStyle(.plain)
            .padding(.bottom, form.birthError == nil ? 8 : 0)

            if let err = form.birthError {
                Text(err)
                    .font(.custom("SF UI Display", size: 14).weight(.light))
                    .kerning(-0.28)
                    .monospacedDigit()
                    .foregroundStyle(Color.red)
                    .padding(.top, 4)
                    .padding(.bottom, 8)
            }
        }
    }

    private func phoneField(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.08))
                )
        }
    }

    private func loadUser() {
        guard let phone = session.currentUserPhone else {
            originalUser = nil
            form.apply(user: nil)
            return
        }

        let user = userStore.user(phone: phone)
        originalUser = user
        form.apply(user: user)
    }

    private func askLogout() {
        router.showConfirmation(
            title: "Выйти из аккаунта?",
            message: "Вы сможете войти снова по коду из смс.",
            confirmTitle: "Выйти",
            cancelTitle: "Отмена",
            isDestructive: true,
            onConfirm: {
                session.signOut()
            }
        )
    }

    private func askDelete() {
        let phoneToDelete = phone
        guard !phoneToDelete.isEmpty else { return }

        router.showConfirmation(
            title: "Удалить аккаунт?",
            message: "Это действие нельзя отменить.",
            confirmTitle: "Удалить",
            cancelTitle: "Отмена",
            isDestructive: true,
            onConfirm: {
                userStore.delete(phone: phoneToDelete)
                session.signOut()
            }
        )
    }
}
