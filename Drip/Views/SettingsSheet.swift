//
//  SettingsSheet.swift
//  Drip
//
//  Settings for daily allowance and seed data
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var dailyAllowanceText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Allowance") {
                    HStack {
                        Text("Current:")
                        Spacer()
                        Text(financeStore.state.dailyAllowance.formattedCurrency())
                            .bold()
                    }

                    TextField("New Daily Allowance", text: $dailyAllowanceText)
                        .keyboardType(.decimalPad)

                    Button("Update Daily Allowance") {
                        updateDailyAllowance()
                    }
                    .disabled(Decimal(string: dailyAllowanceText) == nil || dailyAllowanceText.isEmpty)
                }

                Section("Seed Data") {
                    Button("Load Baseline Seed Data") {
                        loadBaselineSeed()
                    }

                    Text("Bank: $382.19, Cash: $3000, Allowance: $88.41, Main Savings: $3382.19")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                dailyAllowanceText = financeStore.state.dailyAllowance.formatted()
            }
        }
    }

    private func updateDailyAllowance() {
        guard let newAllowance = Decimal(string: dailyAllowanceText) else { return }
        var state = financeStore.state
        state.dailyAllowance = newAllowance
        FinanceEngine.recalculateBuckets(state: &state)
        financeStore.state = state
    }

    private func loadBaselineSeed() {
        financeStore.state = FinancialState.baselineSeed
    }
}
