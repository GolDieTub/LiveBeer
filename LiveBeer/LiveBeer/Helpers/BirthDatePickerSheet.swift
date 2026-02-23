//
//  BirthDatePickerSheet.swift
//  LiveBeer
//
//  Created by  Uladzimir on 23.02.26.
//

import SwiftUI

struct BirthDatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    @Binding var date: Date
    var onCancel: () -> Void
    var onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("Отмена") {
                    onCancel()
                    dismiss()
                }

                Spacer()

                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button("Готово") {
                    onDone()
                    dismiss()
                }
                .font(.system(size: 16, weight: .semibold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            Divider()

            DatePicker("", selection: $date, in: ...Date(), displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)

            Spacer(minLength: 0)
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}
