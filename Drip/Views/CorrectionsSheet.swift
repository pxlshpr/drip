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
    @State private var isNegative: Bool = false
    @State private var description: String = ""
    @State private var toAccount: String = "Bank"
    @State private var date: Date = Date()

    var currentBalance: Decimal {
        toAccount == "Bank" ? financeStore.state.bank : financeStore.state.cashReserve
    }

    var parsedAmount: Decimal {
        let value = Decimal(string: amount) ?? 0
        return isNegative ? -value : value
    }

    var displayAmount: Binding<String> {
        Binding(
            get: {
                if isNegative && !amount.isEmpty {
                    return "-" + amount
                }
                return amount
            },
            set: { newValue in
                amount = newValue.replacingOccurrences(of: "-", with: "")
            }
        )
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

                    HStack {
                        Text("Current Balance")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(currentBalance.formattedCurrency())
                            .fontWeight(.medium)
                    }

                    HStack {
                        Text(inputMode == .trueBalance ? "True Balance" : "Correction Amount")
                            .foregroundStyle(.secondary)
                        Spacer()

                        TextField("", text: displayAmount)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 150)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Button {
                                        isNegative.toggle()
                                    } label: {
                                        Image(systemName: "plus.forwardslash.minus")
                                            .foregroundStyle(isNegative ? .red : .green)
                                    }

                                    Spacer()

                                    Button("Done") {
                                        hideKeyboard()
                                    }
                                }
                            }
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

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
