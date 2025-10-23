//
//  TransferSheet.swift
//  Drip
//
//  Sheet for cash/bank transfers
//

import SwiftUI

enum TransferDirection {
    case withdrawCash
    case depositBank
}

struct TransferSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var direction: TransferDirection = .withdrawCash

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transfer Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Description (optional)", text: $description)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Picker("Direction", selection: $direction) {
                        Text("🏦 → 💵 Withdraw Cash").tag(TransferDirection.withdrawCash)
                        Text("💵 → 🏦 Deposit to Bank").tag(TransferDirection.depositBank)
                    }
                }

                Section {
                    Text(direction == .withdrawCash ?
                         "This will move money from Bank to Cash Reserve." :
                         "This will move money from Cash Reserve to Bank.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Transfer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm") {
                        saveTransfer()
                    }
                    .disabled(parsedAmount <= 0)
                }
            }
        }
    }

    private func saveTransfer() {
        var state = financeStore.state
        let desc = description.isEmpty ?
            (direction == .withdrawCash ? "Cash withdrawal" : "Cash deposit") :
            description

        if direction == .withdrawCash {
            FinanceEngine.withdrawCash(state: &state, amount: parsedAmount, description: desc, date: date)
        } else {
            FinanceEngine.depositCash(state: &state, amount: parsedAmount, description: desc, date: date)
        }

        financeStore.state = state
        dismiss()
    }
}
