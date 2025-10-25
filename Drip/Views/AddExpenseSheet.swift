//
//  AddExpenseSheet.swift
//  Drip
//
//  Sheet for adding expenses with live preview
//

import SwiftUI

struct AddExpenseSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var source: ExpenseSource = .bank
    @State private var fromSavingsConcept: Bool = false
    @State private var countsTowardAllowance: Bool = true

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var previewState: FinancialState {
        var state = financeStore.state
        if parsedAmount > 0 {
            FinanceEngine.addExpense(
                state: &state,
                amount: parsedAmount,
                description: description.isEmpty ? "Expense" : description,
                date: date,
                source: source,
                fromSavingsConcept: fromSavingsConcept,
                countsTowardAllowance: countsTowardAllowance
            )
        }
        return state
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Description", text: $description)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Picker("Source", selection: $source) {
                        Text("🏦 Bank").tag(ExpenseSource.bank)
                        Text("💵 Cash").tag(ExpenseSource.cash)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: source) { _, newValue in
                        // Auto-update countsTowardAllowance based on source
                        countsTowardAllowance = (newValue == .bank)
                    }

                    Toggle("Counts toward daily allowance", isOn: $countsTowardAllowance)

                    Toggle("From Savings (conceptually)", isOn: $fromSavingsConcept)
                }

                if parsedAmount > 0 {
                    Section("Live Preview") {
                        VStack(alignment: .leading, spacing: 8) {
                            PreviewRow(label: "Remaining Allowance", value: FinanceEngine.remainingDailyAllowance(state: previewState, date: date).formattedCurrency())
                            PreviewRow(label: "Bank", value: previewState.bank.formattedCurrency())
                            PreviewRow(label: "Cash Reserve", value: previewState.cashReserve.formattedCurrency())
                            PreviewRow(label: "Main Savings", value: previewState.mainSavings.formattedCurrency())
                        }
                        .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveExpense()
                    }
                    .disabled(parsedAmount <= 0)
                }
            }
        }
    }

    private func saveExpense() {
        var state = financeStore.state
        FinanceEngine.addExpense(
            state: &state,
            amount: parsedAmount,
            description: description.isEmpty ? "Expense" : description,
            date: date,
            source: source,
            fromSavingsConcept: fromSavingsConcept,
            countsTowardAllowance: countsTowardAllowance
        )
        financeStore.state = state
        dismiss()
    }
}

struct PreviewRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .bold()
        }
    }
}
