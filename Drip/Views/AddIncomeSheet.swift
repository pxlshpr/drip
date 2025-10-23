//
//  AddIncomeSheet.swift
//  Drip
//
//  Sheet for adding income
//

import SwiftUI

struct AddIncomeSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var amount: String = ""
    @State private var description: String = ""
    @State private var date: Date = Date()
    @State private var treatAsSavings: Bool = false

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Income Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Description", text: $description)

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    Toggle("Treat as Savings", isOn: $treatAsSavings)
                }
            }
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveIncome()
                    }
                    .disabled(parsedAmount <= 0)
                }
            }
        }
    }

    private func saveIncome() {
        var state = financeStore.state
        FinanceEngine.addIncome(
            state: &state,
            amount: parsedAmount,
            description: description.isEmpty ? "Income" : description,
            date: date,
            treatAsSavings: treatAsSavings
        )
        financeStore.state = state
        dismiss()
    }
}
