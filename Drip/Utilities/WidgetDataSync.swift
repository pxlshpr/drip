//
//  WidgetDataSync.swift
//  Drip
//
//  Syncs financial state to shared UserDefaults for widget access
//

import Foundation
import WidgetKit

struct WidgetDataSync {
    static let appGroupIdentifier = "group.com.ahmdrghb.Drip"
    static let stateKey = "financialState"

    static func syncToWidget(state: FinancialState) {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            print("❌ App: Failed to access shared UserDefaults for widget")
            return
        }

        print("🔄 App: Syncing to widget - mainSavings: \(state.mainSavings)")
        if let encoded = try? JSONEncoder().encode(state) {
            sharedDefaults.set(encoded, forKey: stateKey)
            sharedDefaults.synchronize()
            print("✅ App: Saved \(encoded.count) bytes to UserDefaults")

            // Tell WidgetKit to reload the widget
            WidgetCenter.shared.reloadAllTimelines()
            print("🔄 App: Widget reload requested")
        } else {
            print("❌ App: Failed to encode state")
        }
    }
}
