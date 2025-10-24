//
//  FinanceStore.swift
//  Drip
//
//  SwiftData persistence wrapper for FinancialState
//

import Foundation
import SwiftData

@Model
final class FinanceStore {
    var stateData: Data = Data()

    init(stateData: Data = Data()) {
        self.stateData = stateData
    }

    var state: FinancialState {
        get {
            guard let decoded = try? JSONDecoder().decode(FinancialState.self, from: stateData) else {
                return FinancialState()
            }
            return decoded
        }
        set {
            guard let encoded = try? JSONEncoder().encode(newValue) else { return }
            stateData = encoded

            // Sync to widget whenever state changes
            WidgetDataSync.syncToWidget(state: newValue)
        }
    }
}
