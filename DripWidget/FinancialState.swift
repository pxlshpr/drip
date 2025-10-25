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
    var countsTowardAllowance: Bool

    // Custom decoding to handle backward compatibility
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        description = try container.decode(String.self, forKey: .description)
        amount = try container.decode(Decimal.self, forKey: .amount)
        source = try container.decode(String.self, forKey: .source)
        // If countsTowardAllowance is missing (old data), default based on source
        countsTowardAllowance = try container.decodeIfPresent(Bool.self, forKey: .countsTowardAllowance) ?? (source == "Bank")
    }
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
