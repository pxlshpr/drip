//
//  CorrectionsSheet.swift
//  Drip
//
//  Sheet for balance corrections and reconciliation
//

import SwiftUI

struct CorrectionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var toAccount: String = "Bank"
    @State private var date: Date = Date()

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Correction Details") {
                    TextField("Amount (use +/- for signed delta)", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Reason", text: $description)

                    Picker("To Account", selection: $toAccount) {
                        Text("🏦 Bank").tag("Bank")
                        Text("💵 Cash").tag("Cash")
                    }
                    .pickerStyle(.segmented)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                if financeStore.state.needsReconciliation {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Reconciliation Needed")
                                .font(.headline)
                                .foregroundStyle(.orange)

                            Text("Delta: \(financeStore.state.reconciliationDelta.formattedCurrency())")
                                .font(.subheadline)

                            Button {
                                autoFix()
                            } label: {
                                Label("Auto-Fix (apply to Main Savings)", systemImage: "wrench.and.screwdriver.fill")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Corrections")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyCorrection()
                    }
                    .disabled(parsedAmount == 0 || description.isEmpty)
                }
            }
        }
    }

    private func applyCorrection() {
        var state = financeStore.state
        FinanceEngine.applyCorrection(
            state: &state,
            amount: parsedAmount,
            description: description,
            toAccount: toAccount,
            date: date
        )
        financeStore.state = state
        dismiss()
    }

    private func autoFix() {
        var state = financeStore.state
        FinanceEngine.autoFixReconciliation(state: &state, description: "Auto-reconciliation", date: date)
        financeStore.state = state
        dismiss()
    }
}
