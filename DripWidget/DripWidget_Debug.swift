// Temporary debug version - paste this into DripWidget.swift to test
// if the basic structure works

import WidgetKit
import SwiftUI

struct DebugProvider: TimelineProvider {
    func placeholder(in context: Context) -> DebugEntry {
        DebugEntry(date: Date(), amount: "TEST")
    }

    func getSnapshot(in context: Context, completion: @escaping (DebugEntry) -> ()) {
        let entry = DebugEntry(date: Date(), amount: "$1234.56")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = DebugEntry(date: Date(), amount: "$1234.56")
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct DebugEntry: TimelineEntry {
    let date: Date
    let amount: String
}

struct DebugWidgetView: View {
    var entry: DebugEntry

    var body: some View {
        VStack {
            Text("🛟")
                .font(.largeTitle)
            Text("Buffer")
                .font(.caption)
            Text(entry.amount)
                .font(.headline)
                .foregroundColor(.green)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

// To test: Replace DripWidget body with this:
// StaticConfiguration(kind: kind, provider: DebugProvider()) { entry in
//     DebugWidgetView(entry: entry)
// }
