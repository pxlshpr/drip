//
//  SnapshotView.swift
//  Drip
//
//  Main snapshot display with liquid glass aesthetic
//

import SwiftUI

struct SnapshotView: View {
    let state: FinancialState
    let referenceDate: Date
    @Binding var showUSDSavings: Bool

    private let fxRateUsd: Decimal = 0.73 // Example rate

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Remaining Daily Allowance (Today)
            VStack(alignment: .leading, spacing: 4) {
                Text("🟩 Remaining Daily Allowance (today):")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(FinanceEngine.remainingDailyAllowance(state: state, date: referenceDate).formattedCurrency())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(remainingAllowanceColor)
            }

            Divider()

            // Actual Funds
            VStack(alignment: .leading, spacing: 8) {
                Text("Actual Funds:")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("• 🏦 Bank:")
                        Spacer()
                        Text(state.bank.formattedCurrency())
                            .bold()
                    }

                    HStack {
                        Text("• 💵 Cash Reserve:")
                        Spacer()
                        Text(state.cashReserve.formattedCurrency())
                            .bold()
                    }

                    HStack {
                        Text("• 🔢 Total:")
                        Spacer()
                        Text(state.actualFunds.formattedCurrency())
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }
                .font(.subheadline)
            }

            Divider()

            // Buckets
            VStack(alignment: .leading, spacing: 8) {
                Text("Buckets (must equal Actual Funds):")
                    .font(.headline)

                VStack(alignment: .leading, spacing: 4) {
                    // Set-aside Allowances
                    HStack {
                        Text("• 📦 Set-aside (Allowances):")
                        Spacer()
                        Text(state.setAsideAllowances.formattedCurrency())
                            .bold()
                    }
                    Text("  (includes today)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    // Set-aside Monthly
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text("• 📦 Set-aside (Monthly):")
                            Spacer()
                            Text(state.setAsideMonthly.formattedCurrency())
                                .bold()
                        }

                        if !state.monthlyEarmarks.filter({ $0.isActive && !$0.isPaid }).isEmpty {
                            ForEach(state.monthlyEarmarks.filter { $0.isActive && !$0.isPaid }) { earmark in
                                HStack {
                                    Text("  – \(earmark.name):")
                                    Spacer()
                                    Text(earmark.amount.formattedCurrency())
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Custom Buckets
                    if !state.customBuckets.isEmpty {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text("• 🎯 Custom Buckets (Goals):")
                                Spacer()
                                Text(state.customBuckets.reduce(0) { $0 + $1.amount }.formattedCurrency())
                                    .bold()
                            }

                            ForEach(state.customBuckets) { bucket in
                                HStack {
                                    Text("  – \(bucket.name):")
                                    Spacer()
                                    Text(bucket.amount.formattedCurrency())
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }

                    // Main Savings
                    HStack {
                        Text("• 🛟 Main Savings (Buffer):")
                        Spacer()
                        Text(state.mainSavings.formattedCurrency())
                            .bold()
                            .foregroundStyle(.green)
                    }

                    if showUSDSavings {
                        HStack {
                            Text("  (≈ USD)")
                            Spacer()
                            Text((state.mainSavings * fxRateUsd).formattedCurrency(currencySymbol: "$"))
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }

                    // Total Buckets
                    HStack {
                        Text("• 🔢 Total:")
                        Spacer()
                        Text(state.totalBuckets.formattedCurrency())
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }
                .font(.subheadline)
            }

            // Reconciliation Warning
            if state.needsReconciliation {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Reconciliation needed: \(state.reconciliationDelta.formattedCurrency())")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
                .padding(.vertical, 4)
            }

            Divider()

            // Stoic Quote
            let quote = StoicQuotes.quoteForDay(date: referenceDate)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(quote.emoji)
                    Text("\"\(quote.text)\"")
                        .font(.caption)
                        .italic()
                        .foregroundStyle(.secondary)
                }
                Text("— \(quote.author)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
    }

    private var remainingAllowanceColor: Color {
        let remaining = FinanceEngine.remainingDailyAllowance(state: state, date: referenceDate)
        if remaining >= state.dailyAllowance * 0.5 {
            return .green
        } else if remaining >= 0 {
            return .orange
        } else {
            return .red
        }
    }
}
