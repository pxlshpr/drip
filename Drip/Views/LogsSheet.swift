//
//  LogsSheet.swift
//  Drip
//
//  Sheet for viewing daily logs, cash reserve logs, and corrections
//

import SwiftUI

struct LogsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore

    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                DailyLogView(financeStore: financeStore)
                    .tabItem {
                        Label("Daily", systemImage: "calendar")
                    }
                    .tag(0)

                CashReserveLogView(financeStore: financeStore)
                    .tabItem {
                        Label("Cash", systemImage: "dollarsign.circle")
                    }
                    .tag(1)

                AdjustmentLogView(financeStore: financeStore)
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

// MARK: - Daily Log View

struct DailyLogView: View {
    let financeStore: FinanceStore

    var sortedLogs: [DailyLogEntry] {
        financeStore.state.dailyLogs.sorted { $0.date > $1.date }
    }

    @State private var itemToDelete: (logDate: Date, itemId: UUID)?
    @State private var showDeleteConfirmation = false
    @State private var itemToEdit: (log: DailyLogEntry, item: DailyLogItem)?
    @State private var showEditSheet = false

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
                            .contentShape(Rectangle())
                            .onTapGesture {
                                itemToEdit = (log, item)
                                showEditSheet = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    itemToDelete = (log.date, item.id)
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
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
        .confirmationDialog("Delete this expense?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let toDelete = itemToDelete {
                    var state = financeStore.state
                    FinanceEngine.deleteExpense(state: &state, logDate: toDelete.logDate, itemId: toDelete.itemId)
                    financeStore.state = state
                }
                itemToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                itemToDelete = nil
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let editData = itemToEdit {
                EditDailyLogItemSheet(
                    financeStore: financeStore,
                    log: editData.log,
                    item: editData.item
                )
            }
        }
    }
}

// MARK: - Cash Reserve Log View

struct CashReserveLogView: View {
    let financeStore: FinanceStore

    var sortedLogs: [CashReserveLogEntry] {
        financeStore.state.cashReserveLogs.sorted { $0.date > $1.date }
    }

    @State private var logToDelete: UUID?
    @State private var showDeleteConfirmation = false
    @State private var logToEdit: CashReserveLogEntry?
    @State private var showEditSheet = false

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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        logToEdit = log
                        showEditSheet = true
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            logToDelete = log.id
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .confirmationDialog("Delete this cash reserve transaction?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let logId = logToDelete {
                    var state = financeStore.state
                    FinanceEngine.deleteCashReserveLog(state: &state, logId: logId)
                    financeStore.state = state
                }
                logToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                logToDelete = nil
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let log = logToEdit {
                EditCashReserveLogSheet(financeStore: financeStore, log: log)
            }
        }
    }
}

// MARK: - Adjustment Log View

struct AdjustmentLogView: View {
    let financeStore: FinanceStore

    var sortedLogs: [AdjustmentLogEntry] {
        financeStore.state.adjustmentLogs.sorted { $0.date > $1.date }
    }

    @State private var logToDelete: UUID?
    @State private var showDeleteConfirmation = false
    @State private var logToEdit: AdjustmentLogEntry?
    @State private var showEditSheet = false

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
                    .contentShape(Rectangle())
                    .onTapGesture {
                        logToEdit = log
                        showEditSheet = true
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            logToDelete = log.id
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .confirmationDialog("Delete this adjustment?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let logId = logToDelete {
                    var state = financeStore.state
                    FinanceEngine.deleteAdjustmentLog(state: &state, logId: logId)
                    financeStore.state = state
                }
                logToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                logToDelete = nil
            }
        }
        .sheet(isPresented: $showEditSheet) {
            if let log = logToEdit {
                EditAdjustmentLogSheet(financeStore: financeStore, log: log)
            }
        }
    }
}

// MARK: - Edit Daily Log Item Sheet

struct EditDailyLogItemSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore
    let log: DailyLogEntry
    let item: DailyLogItem

    @State private var description: String
    @State private var amount: String
    @State private var source: ExpenseSource

    init(financeStore: FinanceStore, log: DailyLogEntry, item: DailyLogItem) {
        self.financeStore = financeStore
        self.log = log
        self.item = item
        _description = State(initialValue: item.description)
        _amount = State(initialValue: item.amount.asString())
        _source = State(initialValue: item.source)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Source", selection: $source) {
                        Text("Bank").tag(ExpenseSource.bank)
                        Text("Cash").tag(ExpenseSource.cash)
                        Text("Savings Concept").tag(ExpenseSource.savingsConcept)
                    }
                }

                Section {
                    Button("Delete Expense", role: .destructive) {
                        var state = financeStore.state
                        FinanceEngine.deleteExpense(state: &state, logDate: log.date, itemId: item.id)
                        financeStore.state = state
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountDecimal = Decimal(string: amount) {
                            var state = financeStore.state
                            FinanceEngine.editExpense(
                                state: &state,
                                logDate: log.date,
                                itemId: item.id,
                                newAmount: amountDecimal,
                                newDescription: description,
                                newSource: source
                            )
                            financeStore.state = state
                        }
                        dismiss()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Edit Cash Reserve Log Sheet

struct EditCashReserveLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore
    let log: CashReserveLogEntry

    @State private var description: String
    @State private var amount: String
    @State private var type: CashReserveLogType

    init(financeStore: FinanceStore, log: CashReserveLogEntry) {
        self.financeStore = financeStore
        self.log = log
        _description = State(initialValue: log.description)
        _amount = State(initialValue: log.amount.asString())
        _type = State(initialValue: log.type)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Type", selection: $type) {
                        Text("Withdraw").tag(CashReserveLogType.withdraw)
                        Text("Deposit").tag(CashReserveLogType.deposit)
                    }
                }

                Section {
                    Button("Delete Transaction", role: .destructive) {
                        var state = financeStore.state
                        FinanceEngine.deleteCashReserveLog(state: &state, logId: log.id)
                        financeStore.state = state
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Cash Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountDecimal = Decimal(string: amount) {
                            var state = financeStore.state
                            FinanceEngine.editCashReserveLog(
                                state: &state,
                                logId: log.id,
                                newAmount: amountDecimal,
                                newDescription: description,
                                newType: type
                            )
                            financeStore.state = state
                        }
                        dismiss()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Edit Adjustment Log Sheet

struct EditAdjustmentLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    let financeStore: FinanceStore
    let log: AdjustmentLogEntry

    @State private var description: String
    @State private var amount: String
    @State private var toAccount: String

    init(financeStore: FinanceStore, log: AdjustmentLogEntry) {
        self.financeStore = financeStore
        self.log = log
        _description = State(initialValue: log.description)
        _amount = State(initialValue: log.amount.asString())
        _toAccount = State(initialValue: log.toAccount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("To Account", selection: $toAccount) {
                        Text("Bank").tag("Bank")
                        Text("Cash").tag("Cash")
                        Text("Main Savings").tag("MainSavings")
                    }
                }

                Section {
                    Button("Delete Adjustment", role: .destructive) {
                        var state = financeStore.state
                        FinanceEngine.deleteAdjustmentLog(state: &state, logId: log.id)
                        financeStore.state = state
                        dismiss()
                    }
                }
            }
            .navigationTitle("Edit Adjustment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amountDecimal = Decimal(string: amount) {
                            var state = financeStore.state
                            FinanceEngine.editAdjustmentLog(
                                state: &state,
                                logId: log.id,
                                newAmount: amountDecimal,
                                newDescription: description,
                                newToAccount: toAccount
                            )
                            financeStore.state = state
                        }
                        dismiss()
                    }
                    .disabled(description.isEmpty || amount.isEmpty)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Decimal Extension for String Conversion

extension Decimal {
    func asString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSNumber) ?? "0"
    }
}
