//
//  HomeView.swift
//  Drip
//
//  Main home screen with liquid glass snapshot card
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var stores: [FinanceStore]

    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @State private var showTransfer = false
    @State private var showCorrections = false
    @State private var showBucketsEditor = false
    @State private var showLogs = false
    @State private var showSettings = false
    @State private var showUSDSavings = false

    private var financeStore: FinanceStore {
        // If we have multiple stores due to CloudKit sync conflicts, merge them
        if stores.count > 1 {
            // Keep the store with the most data (largest stateData)
            let primaryStore = stores.max(by: { $0.stateData.count < $1.stateData.count }) ?? stores[0]
            for store in stores where store !== primaryStore {
                modelContext.delete(store)
            }
            try? modelContext.save()
            return primaryStore
        } else if let store = stores.first {
            return store
        } else {
            let newStore = FinanceStore()
            modelContext.insert(newStore)
            try? modelContext.save()
            return newStore
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Liquid Glass Snapshot Card
                    ZStack {
                        // Liquid glass background
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)

                        SnapshotView(
                            state: financeStore.state,
                            referenceDate: Date(),
                            showUSDSavings: $showUSDSavings
                        )
                    }
                    .padding(.horizontal)

                    // Action Buttons
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            ActionButton(icon: "minus.circle.fill", title: "Expense", color: .red) {
                                showAddExpense = true
                            }

                            ActionButton(icon: "plus.circle.fill", title: "Income", color: .green) {
                                showAddIncome = true
                            }
                        }

                        HStack(spacing: 12) {
                            ActionButton(icon: "arrow.left.arrow.right", title: "Transfer", color: .blue) {
                                showTransfer = true
                            }

                            ActionButton(icon: "square.grid.2x2", title: "Buckets", color: .purple) {
                                showBucketsEditor = true
                            }
                        }

                        HStack(spacing: 12) {
                            ActionButton(icon: "list.bullet.clipboard", title: "Logs", color: .orange) {
                                showLogs = true
                            }

                            ActionButton(icon: "gearshape.fill", title: "Settings", color: .gray) {
                                showSettings = true
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Drip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showUSDSavings.toggle()
                    } label: {
                        Image(systemName: showUSDSavings ? "dollarsign.circle.fill" : "dollarsign.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddExpense) {
                AddExpenseSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showAddIncome) {
                AddIncomeSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showTransfer) {
                TransferSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showCorrections) {
                CorrectionsSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showBucketsEditor) {
                BucketsEditorSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showLogs) {
                LogsSheet(state: financeStore.state)
            }
            .sheet(isPresented: $showSettings) {
                SettingsSheet(financeStore: financeStore)
            }
        }
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Spacer()
            }
            .foregroundStyle(.white)
            .padding()
            .background(color.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
