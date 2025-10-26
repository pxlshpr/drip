//
//  CorrectionsSheet.swift
//  Drip
//
//  Sheet for balance corrections and reconciliation
//

import SwiftUI

enum CorrectionInputMode: String, CaseIterable {
    case trueBalance = "True Balance"
    case correctionAmount = "Correction Amount"
}

struct CorrectionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var inputMode: CorrectionInputMode = .trueBalance
    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var toAccount: String = "Bank"
    @State private var date: Date = Date()

    var currentBalance: Decimal {
        toAccount == "Bank" ? financeStore.state.bank : financeStore.state.cashReserve
    }

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var calculatedCorrection: Decimal {
        if inputMode == .trueBalance {
            return parsedAmount - currentBalance
        } else {
            return parsedAmount
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Correction Details") {
                    Picker("Input Mode", selection: $inputMode) {
                        ForEach(CorrectionInputMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("Account", selection: $toAccount) {
                        Text("🏦 Bank").tag("Bank")
                        Text("💵 Cash").tag("Cash")
                    }
                    .pickerStyle(.segmented)

                    if inputMode == .trueBalance {
                        HStack {
                            Text("Current Balance")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(currentBalance.formattedCurrency())
                                .fontWeight(.medium)
                        }

                        TextField("True Balance", text: $amount)
                            .keyboardType(.decimalPad)
                    } else {
                        TextField("Correction Amount (use +/- for signed)", text: $amount)
                            .keyboardType(.decimalPad)
                    }

                    if inputMode == .trueBalance && parsedAmount != 0 {
                        HStack {
                            Text("Required Correction")
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(calculatedCorrection.formattedCurrency())
                                .fontWeight(.medium)
                                .foregroundStyle(calculatedCorrection >= 0 ? .green : .red)
                        }
                    }

                    TextField("Reason", text: $description)

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
                    .disabled(amount.isEmpty || description.isEmpty || calculatedCorrection == 0)
                }
            }
        }
    }

    private func applyCorrection() {
        var state = financeStore.state
        FinanceEngine.applyCorrection(
            state: &state,
            amount: calculatedCorrection,
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
