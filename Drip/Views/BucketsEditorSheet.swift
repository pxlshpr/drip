//
//  BucketsEditorSheet.swift
//  Drip
//
//  Sheet for managing buckets and monthly earmarks
//

import SwiftUI

struct BucketsEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var showAddMonthlyEarmark = false
    @State private var showAddCustomBucket = false

    var body: some View {
        NavigationStack {
            List {
                Section("Monthly Earmarks") {
                    ForEach(financeStore.state.monthlyEarmarks.filter { $0.isActive }) { earmark in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(earmark.name)
                                    .font(.headline)
                                if !earmark.notes.isEmpty {
                                    Text(earmark.notes)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            VStack(alignment: .trailing) {
                                Text(earmark.amount.formattedCurrency())
                                    .bold()

                                if earmark.isPaid {
                                    Text("Paid")
                                        .font(.caption)
                                        .foregroundStyle(.green)
                                }
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                removeEarmark(id: earmark.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            if !earmark.isPaid {
                                Button {
                                    markAsPaid(id: earmark.id)
                                } label: {
                                    Label("Mark Paid", systemImage: "checkmark")
                                }
                                .tint(.green)
                            }
                        }
                    }

                    Button {
                        showAddMonthlyEarmark = true
                    } label: {
                        Label("Add Monthly Earmark", systemImage: "plus.circle")
                    }
                }

                Section("Custom Buckets (Goals)") {
                    ForEach(financeStore.state.customBuckets) { bucket in
                        HStack {
                            Text(bucket.name)
                                .font(.headline)

                            Spacer()

                            Text(bucket.amount.formattedCurrency())
                                .bold()
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                removeCustomBucket(id: bucket.id)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }

                    Button {
                        showAddCustomBucket = true
                    } label: {
                        Label("Add Custom Bucket", systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle("Buckets Editor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddMonthlyEarmark) {
                AddMonthlyEarmarkSheet(financeStore: financeStore)
            }
            .sheet(isPresented: $showAddCustomBucket) {
                AddCustomBucketSheet(financeStore: financeStore)
            }
        }
    }

    private func removeEarmark(id: UUID) {
        var state = financeStore.state
        FinanceEngine.removeMonthlyEarmark(state: &state, id: id, reallocateTo: "mainSavings")
        financeStore.state = state
    }

    private func markAsPaid(id: UUID) {
        guard let earmark = financeStore.state.monthlyEarmarks.first(where: { $0.id == id }) else { return }
        var state = financeStore.state
        FinanceEngine.markMonthlyEarmarkPaid(state: &state, id: id, actualAmountPaid: earmark.amount, paidFrom: .bank)
        financeStore.state = state
    }

    private func removeCustomBucket(id: UUID) {
        var state = financeStore.state
        FinanceEngine.removeCustomBucket(state: &state, id: id)
        financeStore.state = state
    }
}

struct AddMonthlyEarmarkSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var name: String = ""
    @State private var amount: String = ""
    @State private var notes: String = ""

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
                TextField("Notes (optional)", text: $notes)
            }
            .navigationTitle("Add Monthly Earmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addEarmark()
                    }
                    .disabled(name.isEmpty || parsedAmount <= 0)
                }
            }
        }
    }

    private func addEarmark() {
        var state = financeStore.state
        FinanceEngine.addMonthlyEarmark(state: &state, name: name, amount: parsedAmount, notes: notes)
        financeStore.state = state
        dismiss()
    }
}

struct AddCustomBucketSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var name: String = ""
    @State private var amount: String = ""

    var parsedAmount: Decimal {
        Decimal(string: amount) ?? 0
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Add Custom Bucket")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addBucket()
                    }
                    .disabled(name.isEmpty || parsedAmount <= 0)
                }
            }
        }
    }

    private func addBucket() {
        var state = financeStore.state
        FinanceEngine.addCustomBucket(state: &state, name: name, amount: parsedAmount)
        financeStore.state = state
        dismiss()
    }
}
