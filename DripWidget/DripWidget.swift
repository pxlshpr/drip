//
//  DripWidget.swift
//  DripWidget
//
//  Created by Ahmed Khalaf on 10/24/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), dailyAllowance: 88.41, savingsBuffer: 1234.56)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let (dailyAllowance, savingsBuffer) = getFinancialData()
        let entry = SimpleEntry(date: Date(), dailyAllowance: dailyAllowance, savingsBuffer: savingsBuffer)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let (dailyAllowance, savingsBuffer) = getFinancialData()
        let entry = SimpleEntry(date: currentDate, dailyAllowance: dailyAllowance, savingsBuffer: savingsBuffer)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getFinancialData() -> (dailyAllowance: Decimal, savingsBuffer: Decimal) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.ahmdrghb.Drip") else {
            print("❌ Widget: Failed to access App Group")
            return (0, 0)
        }

        print("🔍 Widget: Checking UserDefaults for key 'financialState'")
        guard let savedData = sharedDefaults.data(forKey: "financialState") else {
            print("❌ Widget: No data found in App Group")
            print("🔍 Widget: All keys in UserDefaults: \(sharedDefaults.dictionaryRepresentation().keys)")
            return (0, 0)
        }

        print("✅ Widget: Found data, size: \(savedData.count) bytes")
        guard let state = try? JSONDecoder().decode(FinancialState.self, from: savedData) else {
            print("❌ Widget: Failed to decode financial state")
            return (0, 0)
        }

        // Calculate remaining daily allowance (subtract today's bank expenses)
        let remainingAllowance = calculateRemainingDailyAllowance(state: state)

        print("✅ Widget: Loaded data - remainingAllowance: \(remainingAllowance), mainSavings: \(state.mainSavings)")
        return (remainingAllowance, state.mainSavings)
    }

    private func calculateRemainingDailyAllowance(state: FinancialState, date: Date = Date()) -> Decimal {
        let calendar = Calendar.current
        guard let todayLog = state.dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) else {
            return state.dailyAllowance
        }

        let spentToday = todayLog.items.filter { $0.source == "bank" }.reduce(Decimal(0)) { $0 + $1.amount }
        return state.dailyAllowance - spentToday
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let dailyAllowance: Decimal
    let savingsBuffer: Decimal
}

struct DripWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("Dailies Bucket")
                        .font(.system(size: 11, weight: .medium))
                        .textCase(.uppercase)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(formatCurrency(entry.dailyAllowance))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                        HStack(spacing: 4) {
                            Image(systemName: "banknote")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                            Text(formatCurrency(entry.savingsBuffer))
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding(12)
        }
    }

    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

struct DripWidget: Widget {
    let kind: String = "DripWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DripWidgetEntryView(entry: entry)
                .containerBackground(.clear, for: .widget)
        }
        .configurationDisplayName("Savings Buffer")
        .description("Shows your current savings buffer amount.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DripWidget()
} timeline: {
    SimpleEntry(date: .now, dailyAllowance: 88.41, savingsBuffer: 1234.56)
    SimpleEntry(date: .now, dailyAllowance: 265.23, savingsBuffer: 5678.90)
}
