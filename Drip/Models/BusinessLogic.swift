//
//  BusinessLogic.swift
//  Drip
//
//  Pure Swift business logic for finance tracking
//

import Foundation

// MARK: - Core Models

struct MonthlyEarmark: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var amount: Decimal
    var notes: String
    var sourceTag: String
    var isActive: Bool
    var isPaid: Bool

    init(id: UUID = UUID(), name: String, amount: Decimal, notes: String = "", sourceTag: String = "", isActive: Bool = true, isPaid: Bool = false) {
        self.id = id
        self.name = name
        self.amount = amount
        self.notes = notes
        self.sourceTag = sourceTag
        self.isActive = isActive
        self.isPaid = isPaid
    }
}

struct CustomBucket: Codable, Identifiable, Equatable {
    let id: UUID
    var name: String
    var amount: Decimal

    init(id: UUID = UUID(), name: String, amount: Decimal) {
        self.id = id
        self.name = name
        self.amount = amount
    }
}

enum ExpenseSource: String, Codable {
    case bank = "Bank"
    case cash = "Cash"
    case savingsConcept = "SavingsConcept"
}

struct DailyLogItem: Codable, Identifiable, Equatable {
    let id: UUID
    var description: String
    var amount: Decimal
    var source: ExpenseSource

    init(id: UUID = UUID(), description: String, amount: Decimal, source: ExpenseSource) {
        self.id = id
        self.description = description
        self.amount = amount
        self.source = source
    }
}

struct DailyLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var items: [DailyLogItem]
    var allowanceDiff: Decimal

    init(id: UUID = UUID(), date: Date, items: [DailyLogItem] = [], allowanceDiff: Decimal = 0) {
        self.id = id
        self.date = date
        self.items = items
        self.allowanceDiff = allowanceDiff
    }
}

enum CashReserveLogType: String, Codable {
    case withdraw
    case deposit
}

struct CashReserveLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var type: CashReserveLogType

    init(id: UUID = UUID(), date: Date, description: String, amount: Decimal, type: CashReserveLogType) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.type = type
    }
}

struct AdjustmentLogEntry: Codable, Identifiable, Equatable {
    let id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var fromAccount: String
    var toAccount: String

    init(id: UUID = UUID(), date: Date, description: String, amount: Decimal, fromAccount: String, toAccount: String) {
        self.id = id
        self.date = date
        self.description = description
        self.amount = amount
        self.fromAccount = fromAccount
        self.toAccount = toAccount
    }
}

// MARK: - Financial State

struct FinancialState: Codable, Equatable {
    var bank: Decimal
    var cashReserve: Decimal
    var dailyAllowance: Decimal
    var setAsideAllowances: Decimal
    var setAsideMonthly: Decimal
    var monthlyEarmarks: [MonthlyEarmark]
    var customBuckets: [CustomBucket]
    var mainSavings: Decimal
    var dailyLogs: [DailyLogEntry]
    var cashReserveLogs: [CashReserveLogEntry]
    var adjustmentLogs: [AdjustmentLogEntry]

    var actualFunds: Decimal {
        bank + cashReserve
    }

    var totalBuckets: Decimal {
        setAsideAllowances + setAsideMonthly + customBuckets.reduce(0) { $0 + $1.amount } + mainSavings
    }

    var reconciliationDelta: Decimal {
        actualFunds - totalBuckets
    }

    var needsReconciliation: Bool {
        abs(reconciliationDelta) >= 0.01
    }

    init(
        bank: Decimal = 0,
        cashReserve: Decimal = 0,
        dailyAllowance: Decimal = 88.41,
        setAsideAllowances: Decimal = 0,
        setAsideMonthly: Decimal = 0,
        monthlyEarmarks: [MonthlyEarmark] = [],
        customBuckets: [CustomBucket] = [],
        mainSavings: Decimal = 0,
        dailyLogs: [DailyLogEntry] = [],
        cashReserveLogs: [CashReserveLogEntry] = [],
        adjustmentLogs: [AdjustmentLogEntry] = []
    ) {
        self.bank = bank
        self.cashReserve = cashReserve
        self.dailyAllowance = dailyAllowance
        self.setAsideAllowances = setAsideAllowances
        self.setAsideMonthly = setAsideMonthly
        self.monthlyEarmarks = monthlyEarmarks
        self.customBuckets = customBuckets
        self.mainSavings = mainSavings
        self.dailyLogs = dailyLogs
        self.cashReserveLogs = cashReserveLogs
        self.adjustmentLogs = adjustmentLogs
    }

    static var baselineSeed: FinancialState {
        // Create a date for Oct 20, 2025 (Monday)
        let calendar = Calendar.current
        var components = DateComponents(year: 2025, month: 10, day: 20)
        let oct20 = calendar.date(from: components)!

        // Create Oct 14 for Claude Max payment date
        components.day = 14
        let oct14 = calendar.date(from: components)!

        // Create monthly earmarks
        let spotify = MonthlyEarmark(name: "Spotify", amount: 41.83, notes: "", sourceTag: "", isActive: true, isPaid: false)
        let chatgpt = MonthlyEarmark(name: "ChatGPT", amount: 308.25, notes: "", sourceTag: "", isActive: true, isPaid: false)
        let misc = MonthlyEarmark(name: "Misc", amount: 80.28, notes: "", sourceTag: "", isActive: true, isPaid: false)
        let claudeMax = MonthlyEarmark(name: "Claude Max", amount: 1460.74, notes: "Paid on Oct 14", sourceTag: "", isActive: true, isPaid: true)

        // Create a daily log entry for Oct 20 showing full allowance spent
        let dailyLogOct20 = DailyLogEntry(
            date: oct20,
            items: [
                DailyLogItem(description: "Daily spending", amount: 88.41, source: .bank)
            ],
            allowanceDiff: 0.00
        )

        // Create cash reserve log for the 3500 deposit
        let cashReserveLog = CashReserveLogEntry(
            date: oct20,
            description: "Cash reserve deposit",
            amount: 3500.00,
            type: .deposit
        )

        return FinancialState(
            bank: 2543.28,
            cashReserve: 3500.00,
            dailyAllowance: 88.41,
            setAsideAllowances: 972.51,  // 12 days remaining (Oct 20-31 inclusive) - includes today
            setAsideMonthly: 430.36,  // Spotify (41.83) + ChatGPT (308.25) + Claude Max (80.28) = 430.36 (Claude Max partially allocated before payment)
            monthlyEarmarks: [spotify, chatgpt, misc, claudeMax],
            customBuckets: [],
            mainSavings: 4640.41,  // Buffer: 6043.28 - 972.51 - 430.36 = 4640.41
            dailyLogs: [dailyLogOct20],
            cashReserveLogs: [cashReserveLog],
            adjustmentLogs: []
        )
    }
}

// MARK: - Business Logic Engine

class FinanceEngine {

    // MARK: - Date Utilities

    static func remainingDaysInclusive(from date: Date, calendar: Calendar = .current) -> Int {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: calendar.date(from: calendar.dateComponents([.year, .month], from: startOfDay))!) else {
            return 0
        }
        let endOfMonthDay = calendar.startOfDay(for: endOfMonth)
        let components = calendar.dateComponents([.day], from: startOfDay, to: endOfMonthDay)
        return (components.day ?? 0) + 1 // inclusive
    }

    // MARK: - Bucket Recalculation

    static func recalculateBuckets(state: inout FinancialState, referenceDate: Date = Date()) {
        // Recompute setAsideAllowances based on remaining days
        let remainingDays = remainingDaysInclusive(from: referenceDate)
        state.setAsideAllowances = state.dailyAllowance * Decimal(remainingDays)

        // Recompute setAsideMonthly from active earmarks
        state.setAsideMonthly = state.monthlyEarmarks.filter { $0.isActive && !$0.isPaid }.reduce(0) { $0 + $1.amount }

        // Recalculate mainSavings as remainder
        let usedBuckets = state.setAsideAllowances + state.setAsideMonthly + state.customBuckets.reduce(0) { $0 + $1.amount }
        state.mainSavings = state.actualFunds - usedBuckets
    }

    // MARK: - Add Expense

    static func addExpense(
        state: inout FinancialState,
        amount: Decimal,
        description: String,
        date: Date = Date(),
        source: ExpenseSource = .bank,
        fromSavingsConcept: Bool = false
    ) {
        // Deduct from account
        switch source {
        case .bank:
            state.bank -= amount
        case .cash:
            state.cashReserve -= amount
        case .savingsConcept:
            // Conceptual only, still comes from bank physically
            state.bank -= amount
        }

        // Log the expense
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        if let existingLogIndex = state.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) {
            var log = state.dailyLogs[existingLogIndex]
            log.items.append(DailyLogItem(description: description, amount: amount, source: source))
            state.dailyLogs[existingLogIndex] = log
        } else {
            var newLog = DailyLogEntry(date: startOfDay)
            newLog.items.append(DailyLogItem(description: description, amount: amount, source: source))
            state.dailyLogs.append(newLog)
        }

        // Recalculate allowance diff for this day
        recalculateAllowanceDiff(state: &state, forDate: date)

        // If marked as from savings conceptually, deduct from mainSavings additionally
        if fromSavingsConcept {
            state.mainSavings -= amount
        }

        // Recalculate buckets
        recalculateBuckets(state: &state, referenceDate: date)
    }

    // MARK: - Add Income

    static func addIncome(
        state: inout FinancialState,
        amount: Decimal,
        description: String,
        date: Date = Date(),
        treatAsSavings: Bool = false
    ) {
        // Add to bank
        state.bank += amount

        // If treat as savings, add to mainSavings conceptually
        if treatAsSavings {
            state.mainSavings += amount
        }

        // Recalculate buckets
        recalculateBuckets(state: &state, referenceDate: date)
    }

    // MARK: - Transfer

    static func withdrawCash(
        state: inout FinancialState,
        amount: Decimal,
        description: String = "Cash withdrawal",
        date: Date = Date()
    ) {
        state.bank -= amount
        state.cashReserve += amount

        // Log cash reserve movement
        state.cashReserveLogs.append(CashReserveLogEntry(
            date: date,
            description: description,
            amount: amount,
            type: .withdraw
        ))

        // No bucket recalc needed, total funds unchanged
    }

    static func depositCash(
        state: inout FinancialState,
        amount: Decimal,
        description: String = "Cash deposit",
        date: Date = Date()
    ) {
        state.cashReserve -= amount
        state.bank += amount

        // Log cash reserve movement
        state.cashReserveLogs.append(CashReserveLogEntry(
            date: date,
            description: description,
            amount: amount,
            type: .deposit
        ))

        // No bucket recalc needed, total funds unchanged
    }

    // MARK: - Corrections

    static func applyCorrection(
        state: inout FinancialState,
        amount: Decimal,
        description: String,
        toAccount: String, // "Bank" or "Cash"
        date: Date = Date()
    ) {
        if toAccount == "Bank" {
            state.bank += amount
        } else if toAccount == "Cash" {
            state.cashReserve += amount
        }

        // Log adjustment
        state.adjustmentLogs.append(AdjustmentLogEntry(
            date: date,
            description: description,
            amount: amount,
            fromAccount: "Correction",
            toAccount: toAccount
        ))

        // Recalculate buckets to match new actual funds
        recalculateBuckets(state: &state, referenceDate: date)
    }

    // MARK: - Monthly Earmarks

    static func addMonthlyEarmark(
        state: inout FinancialState,
        name: String,
        amount: Decimal,
        notes: String = "",
        sourceTag: String = ""
    ) {
        let earmark = MonthlyEarmark(name: name, amount: amount, notes: notes, sourceTag: sourceTag)
        state.monthlyEarmarks.append(earmark)
        recalculateBuckets(state: &state)
    }

    static func removeMonthlyEarmark(
        state: inout FinancialState,
        id: UUID,
        reallocateTo: String = "mainSavings" // "mainSavings", "allowances", or custom bucket name
    ) {
        guard let index = state.monthlyEarmarks.firstIndex(where: { $0.id == id }) else { return }
        let earmark = state.monthlyEarmarks[index]
        state.monthlyEarmarks.remove(at: index)

        // Reallocate based on instruction
        if reallocateTo == "allowances" {
            // Add to allowances conceptually (would increase days or allowance amount - for simplicity add to mainSavings)
            state.mainSavings += earmark.amount
        } else if reallocateTo == "mainSavings" {
            state.mainSavings += earmark.amount
        } else {
            // Reallocate to custom bucket
            if let bucketIndex = state.customBuckets.firstIndex(where: { $0.name == reallocateTo }) {
                state.customBuckets[bucketIndex].amount += earmark.amount
            }
        }

        recalculateBuckets(state: &state)
    }

    static func markMonthlyEarmarkPaid(
        state: inout FinancialState,
        id: UUID,
        actualAmountPaid: Decimal,
        paidFrom: ExpenseSource = .bank,
        date: Date = Date()
    ) {
        guard let index = state.monthlyEarmarks.firstIndex(where: { $0.id == id }) else { return }
        var earmark = state.monthlyEarmarks[index]
        let earmarkedAmount = earmark.amount
        earmark.isPaid = true
        state.monthlyEarmarks[index] = earmark

        // Deduct actual payment from account
        switch paidFrom {
        case .bank:
            state.bank -= actualAmountPaid
        case .cash:
            state.cashReserve -= actualAmountPaid
        case .savingsConcept:
            state.bank -= actualAmountPaid
        }

        // Calculate difference
        let difference = earmarkedAmount - actualAmountPaid

        // Return difference to mainSavings
        state.mainSavings += difference

        recalculateBuckets(state: &state, referenceDate: date)
    }

    // MARK: - Custom Buckets

    static func addCustomBucket(state: inout FinancialState, name: String, amount: Decimal) {
        let bucket = CustomBucket(name: name, amount: amount)
        state.customBuckets.append(bucket)
        recalculateBuckets(state: &state)
    }

    static func removeCustomBucket(state: inout FinancialState, id: UUID) {
        state.customBuckets.removeAll { $0.id == id }
        recalculateBuckets(state: &state)
    }

    // MARK: - Auto-fix Reconciliation

    static func autoFixReconciliation(state: inout FinancialState, description: String = "Auto-reconciliation", date: Date = Date()) {
        let delta = state.reconciliationDelta
        if abs(delta) >= 0.01 {
            state.mainSavings += delta

            state.adjustmentLogs.append(AdjustmentLogEntry(
                date: date,
                description: description,
                amount: delta,
                fromAccount: "Reconciliation",
                toAccount: "MainSavings"
            ))
        }
    }

    // MARK: - Remaining Daily Allowance (Today)

    static func remainingDailyAllowance(state: FinancialState, date: Date = Date()) -> Decimal {
        let calendar = Calendar.current
        guard let todayLog = state.dailyLogs.first(where: { calendar.isDate($0.date, inSameDayAs: date) }) else {
            return state.dailyAllowance
        }

        let spentToday = todayLog.items.filter { $0.source == .bank }.reduce(Decimal(0)) { $0 + $1.amount }
        return state.dailyAllowance - spentToday
    }

    // MARK: - Recalculate Allowance Diff

    static func recalculateAllowanceDiff(state: inout FinancialState, forDate date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        guard let logIndex = state.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }) else {
            return
        }

        let log = state.dailyLogs[logIndex]
        let spentFromBank = log.items.filter { $0.source == .bank }.reduce(Decimal(0)) { $0 + $1.amount }
        let diff = state.dailyAllowance - spentFromBank
        state.dailyLogs[logIndex].allowanceDiff = diff
    }

    /// Recalculates allowance diff for all daily logs
    static func recalculateAllAllowanceDiffs(state: inout FinancialState) {
        for i in state.dailyLogs.indices {
            let log = state.dailyLogs[i]
            let spentFromBank = log.items.filter { $0.source == .bank }.reduce(Decimal(0)) { $0 + $1.amount }
            let diff = state.dailyAllowance - spentFromBank
            state.dailyLogs[i].allowanceDiff = diff
        }
    }

    // MARK: - Delete Expense

    static func deleteExpense(
        state: inout FinancialState,
        logDate: Date,
        itemId: UUID
    ) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)

        guard let logIndex = state.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }),
              let itemIndex = state.dailyLogs[logIndex].items.firstIndex(where: { $0.id == itemId }) else {
            return
        }

        let item = state.dailyLogs[logIndex].items[itemIndex]

        // Refund to account
        switch item.source {
        case .bank:
            state.bank += item.amount
        case .cash:
            state.cashReserve += item.amount
        case .savingsConcept:
            state.bank += item.amount
        }

        // Remove item from log
        state.dailyLogs[logIndex].items.remove(at: itemIndex)

        // If no items left in this day, remove the entire log entry
        if state.dailyLogs[logIndex].items.isEmpty {
            state.dailyLogs.remove(at: logIndex)
        } else {
            // Recalculate allowance diff for this day
            recalculateAllowanceDiff(state: &state, forDate: logDate)
        }

        // Recalculate buckets
        recalculateBuckets(state: &state, referenceDate: logDate)
    }

    // MARK: - Edit Expense

    static func editExpense(
        state: inout FinancialState,
        logDate: Date,
        itemId: UUID,
        newAmount: Decimal,
        newDescription: String,
        newSource: ExpenseSource
    ) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: logDate)

        guard let logIndex = state.dailyLogs.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: startOfDay) }),
              let itemIndex = state.dailyLogs[logIndex].items.firstIndex(where: { $0.id == itemId }) else {
            return
        }

        let oldItem = state.dailyLogs[logIndex].items[itemIndex]

        // Refund old amount
        switch oldItem.source {
        case .bank:
            state.bank += oldItem.amount
        case .cash:
            state.cashReserve += oldItem.amount
        case .savingsConcept:
            state.bank += oldItem.amount
        }

        // Deduct new amount
        switch newSource {
        case .bank:
            state.bank -= newAmount
        case .cash:
            state.cashReserve -= newAmount
        case .savingsConcept:
            state.bank -= newAmount
        }

        // Update item
        state.dailyLogs[logIndex].items[itemIndex].amount = newAmount
        state.dailyLogs[logIndex].items[itemIndex].description = newDescription
        state.dailyLogs[logIndex].items[itemIndex].source = newSource

        // Recalculate allowance diff for this day
        recalculateAllowanceDiff(state: &state, forDate: logDate)

        // Recalculate buckets
        recalculateBuckets(state: &state, referenceDate: logDate)
    }

    // MARK: - Delete Cash Reserve Log

    static func deleteCashReserveLog(state: inout FinancialState, logId: UUID) {
        guard let logIndex = state.cashReserveLogs.firstIndex(where: { $0.id == logId }) else {
            return
        }

        let log = state.cashReserveLogs[logIndex]

        // Reverse the transaction
        switch log.type {
        case .withdraw:
            // Was: bank -= amount, cashReserve += amount
            // Reverse: bank += amount, cashReserve -= amount
            state.bank += log.amount
            state.cashReserve -= log.amount
        case .deposit:
            // Was: cashReserve -= amount, bank += amount
            // Reverse: cashReserve += amount, bank -= amount
            state.cashReserve += log.amount
            state.bank -= log.amount
        }

        // Remove log
        state.cashReserveLogs.remove(at: logIndex)

        // No bucket recalc needed, total funds unchanged
    }

    // MARK: - Edit Cash Reserve Log

    static func editCashReserveLog(
        state: inout FinancialState,
        logId: UUID,
        newAmount: Decimal,
        newDescription: String,
        newType: CashReserveLogType
    ) {
        guard let logIndex = state.cashReserveLogs.firstIndex(where: { $0.id == logId }) else {
            return
        }

        let oldLog = state.cashReserveLogs[logIndex]

        // Reverse old transaction
        switch oldLog.type {
        case .withdraw:
            state.bank += oldLog.amount
            state.cashReserve -= oldLog.amount
        case .deposit:
            state.cashReserve += oldLog.amount
            state.bank -= oldLog.amount
        }

        // Apply new transaction
        switch newType {
        case .withdraw:
            state.bank -= newAmount
            state.cashReserve += newAmount
        case .deposit:
            state.cashReserve -= newAmount
            state.bank += newAmount
        }

        // Update log
        state.cashReserveLogs[logIndex].amount = newAmount
        state.cashReserveLogs[logIndex].description = newDescription
        state.cashReserveLogs[logIndex].type = newType

        // No bucket recalc needed, total funds unchanged
    }

    // MARK: - Delete Adjustment Log

    static func deleteAdjustmentLog(state: inout FinancialState, logId: UUID) {
        guard let logIndex = state.adjustmentLogs.firstIndex(where: { $0.id == logId }) else {
            return
        }

        let log = state.adjustmentLogs[logIndex]

        // Reverse the adjustment
        if log.toAccount == "Bank" {
            state.bank -= log.amount
        } else if log.toAccount == "Cash" {
            state.cashReserve -= log.amount
        } else if log.toAccount == "MainSavings" {
            state.mainSavings -= log.amount
        }

        // Remove log
        state.adjustmentLogs.remove(at: logIndex)

        // Recalculate buckets
        recalculateBuckets(state: &state)
    }

    // MARK: - Edit Adjustment Log

    static func editAdjustmentLog(
        state: inout FinancialState,
        logId: UUID,
        newAmount: Decimal,
        newDescription: String,
        newToAccount: String
    ) {
        guard let logIndex = state.adjustmentLogs.firstIndex(where: { $0.id == logId }) else {
            return
        }

        let oldLog = state.adjustmentLogs[logIndex]

        // Reverse old adjustment
        if oldLog.toAccount == "Bank" {
            state.bank -= oldLog.amount
        } else if oldLog.toAccount == "Cash" {
            state.cashReserve -= oldLog.amount
        } else if oldLog.toAccount == "MainSavings" {
            state.mainSavings -= oldLog.amount
        }

        // Apply new adjustment
        if newToAccount == "Bank" {
            state.bank += newAmount
        } else if newToAccount == "Cash" {
            state.cashReserve += newAmount
        } else if newToAccount == "MainSavings" {
            state.mainSavings += newAmount
        }

        // Update log
        state.adjustmentLogs[logIndex].amount = newAmount
        state.adjustmentLogs[logIndex].description = newDescription
        state.adjustmentLogs[logIndex].toAccount = newToAccount

        // Recalculate buckets
        recalculateBuckets(state: &state)
    }
}
