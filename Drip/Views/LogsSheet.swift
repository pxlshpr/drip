//
//  LogsSheet.swift
//  Drip
//
//  Sheet for viewing daily logs, cash reserve logs, and corrections
//

import SwiftUI

struct LogsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let state: FinancialState

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DailyLogView(logs: state.dailyLogs)
                    .tabItem {
                        Label("Daily", systemImage: "calendar")
                    }
                    .tag(0)

                CashReserveLogView(logs: state.cashReserveLogs)
                    .tabItem {
                        Label("Cash", systemImage: "dollarsign.circle")
                    }
                    .tag(1)

                AdjustmentLogView(logs: state.adjustmentLogs)
                    .tabItem {
                        Label("Corrections", systemImage: "wrench.and.screwdriver")
                    }
                    .tag(2)
            }
            .navigationTitle("Logs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DailyLogView: View {
    let logs: [DailyLogEntry]

    var sortedLogs: [DailyLogEntry] {
        logs.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if sortedLogs.isEmpty {
                Text("No daily logs yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedLogs) { log in
                    Section(log.date.formattedMedium()) {
                        ForEach(log.items) { item in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.description)
                                        .font(.headline)
                                    Text(item.source.rawValue)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Text(item.amount.formattedCurrency())
                                    .bold()
                            }
                        }

                        if log.allowanceDiff != 0 {
                            HStack {
                                Text("Allowance Diff")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(log.allowanceDiff.formattedCurrency())
                                    .font(.caption)
                                    .foregroundStyle(log.allowanceDiff >= 0 ? .green : .red)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct CashReserveLogView: View {
    let logs: [CashReserveLogEntry]

    var sortedLogs: [CashReserveLogEntry] {
        logs.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if sortedLogs.isEmpty {
                Text("No cash reserve logs yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedLogs) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.description)
                                .font(.headline)
                            HStack {
                                Text(log.date.formattedShort())
                                Text("•")
                                Text(log.type.rawValue.capitalized)
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(log.amount.formattedCurrency())
                            .bold()
                            .foregroundStyle(log.type == .withdraw ? .red : .green)
                    }
                }
            }
        }
    }
}

struct AdjustmentLogView: View {
    let logs: [AdjustmentLogEntry]

    var sortedLogs: [AdjustmentLogEntry] {
        logs.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            if sortedLogs.isEmpty {
                Text("No adjustment logs yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(sortedLogs) { log in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(log.description)
                                .font(.headline)
                            HStack {
                                Text(log.date.formattedShort())
                                Text("•")
                                Text("\(log.fromAccount) → \(log.toAccount)")
                            }
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(log.amount.formattedCurrency())
                            .bold()
                            .foregroundStyle(log.amount >= 0 ? .green : .red)
                    }
                }
            }
        }
    }
}
