import Foundation

// Shared FinancialState model for the widget
// This is a simplified version that only includes what we need for decoding
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
}

struct MonthlyEarmark: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var amount: Decimal
    var notes: String
    var sourceTag: String
    var isActive: Bool
    var isPaid: Bool
}

struct CustomBucket: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var amount: Decimal
}

struct DailyLogItem: Codable, Equatable, Identifiable {
    var id: UUID
    var description: String
    var amount: Decimal
    var source: String
}

struct DailyLogEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var items: [DailyLogItem]
    var allowanceDiff: Decimal
}

struct CashReserveLogEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var type: String
}

struct AdjustmentLogEntry: Codable, Equatable, Identifiable {
    var id: UUID
    var date: Date
    var description: String
    var amount: Decimal
    var fromAccount: String
    var toAccount: String
}
