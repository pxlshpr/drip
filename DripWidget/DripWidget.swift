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
        SimpleEntry(date: Date(), savingsBuffer: 1234.56)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), savingsBuffer: getSavingsBuffer())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let savingsBuffer = getSavingsBuffer()
        let entry = SimpleEntry(date: currentDate, savingsBuffer: savingsBuffer)

        // Update every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getSavingsBuffer() -> Decimal {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.ahmdrghb.Drip") else {
            print("❌ Widget: Failed to access App Group")
            return 0
        }

        guard let savedData = sharedDefaults.data(forKey: "financialState") else {
            print("❌ Widget: No data found in App Group")
            return 0
        }

        guard let state = try? JSONDecoder().decode(FinancialState.self, from: savedData) else {
            print("❌ Widget: Failed to decode financial state")
            return 0
        }

        print("✅ Widget: Loaded savings buffer: \(state.mainSavings)")
        return state.mainSavings
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let savingsBuffer: Decimal
}

struct DripWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 6) {
            Text("🛟")
                .font(.system(size: 28))

            Text("Buffer")
                .font(.system(size: 10, weight: .medium))
                .textCase(.uppercase)

            if entry.savingsBuffer == 0 {
                Text("Open App")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)
            } else {
                Text(formatCurrency(entry.savingsBuffer))
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
        .padding(8)
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
        }
        .configurationDisplayName("Savings Buffer")
        .description("Shows your current savings buffer amount.")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DripWidget()
} timeline: {
    SimpleEntry(date: .now, savingsBuffer: 1234.56)
    SimpleEntry(date: .now, savingsBuffer: 5678.90)
}
