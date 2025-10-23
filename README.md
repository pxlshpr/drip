# Drip - Minimal iOS Daily Allowance / Buckets Tracker

A minimal, production-ready iOS app (iOS 26+) for personal finance tracking with a bucket-based allowance system. Built with SwiftUI and SwiftData.

## Overview

Drip helps you manage your finances using a simple bucket allocation system:
- **Daily Allowance**: Track daily spending against a fixed allowance
- **Monthly Set-Asides**: Earmark funds for recurring monthly expenses
- **Custom Buckets**: Create savings goals and track progress
- **Main Savings**: Automatic buffer/remainder calculation

The app ensures that your buckets always equal your actual funds (Bank + Cash Reserve), providing real-time reconciliation and balance tracking.

## Features

### Core Functionality
- ✅ Daily allowance tracking with automatic rollover
- ✅ Bank and Cash Reserve account management
- ✅ Expense tracking from Bank or Cash
- ✅ Income tracking with optional savings allocation
- ✅ Cash transfers (withdraw/deposit)
- ✅ Balance corrections and reconciliation
- ✅ Monthly earmarks with paid/unpaid tracking
- ✅ Custom savings buckets
- ✅ Comprehensive logging (Daily, Cash Reserve, Corrections)

### UI/UX
- 🎨 Liquid glass aesthetic with frosted blur effects
- 📱 Native iOS components and design patterns
- 🌗 Dark/Light mode support
- ♿ Accessibility-ready
- 📊 Live preview of balance changes in expense sheets
- 📜 Daily rotating Stoic quotes about money

### Data & Persistence
- 💾 SwiftData local persistence
- 🔒 All data stays on device
- 🧪 Comprehensive unit test coverage
- 🌱 Seed data for testing/demo

## Architecture

### Business Logic Layer (`Drip/Models/BusinessLogic.swift`)
Pure Swift implementation of all finance rules. Completely independent of UI, making it:
- Testable in isolation
- Reusable across platforms
- Easy to reason about and maintain

Key classes:
- `FinancialState`: Core state model
- `FinanceEngine`: All business logic operations (static methods)
- Models: `MonthlyEarmark`, `CustomBucket`, `DailyLogEntry`, etc.

### Persistence Layer (`Drip/Models/FinanceStore.swift`)
SwiftData wrapper that serializes `FinancialState` to JSON for persistence.

### UI Layer (`Drip/Views/`)
SwiftUI views following iOS patterns:
- `HomeView`: Main snapshot card with action buttons
- `SnapshotView`: Formatted balance display
- Sheet views for all operations (Expense, Income, Transfer, etc.)

### Utilities
- `FormatUtilities.swift`: Currency and date formatting
- `StoicQuotes.swift`: Rotating daily quotes

## Business Rules

### Bucket Reconciliation
**Rule**: `Bank + Cash Reserve = Sum of All Buckets`

Buckets consist of:
1. Set-aside (Allowances) = `dailyAllowance × remainingDaysInMonth` (inclusive of today)
2. Set-aside (Monthly) = Sum of active, unpaid monthly earmarks
3. Custom Buckets = User-defined savings goals
4. Main Savings = Remainder (buffer)

The app automatically recalculates buckets after every operation.

### Daily Allowance Logic
- Today's allowance is **always included** in the set-aside allowances bucket
- When you spend less than your daily allowance, the difference goes to Main Savings
- When you overspend, the excess is deducted from Main Savings
- Only expenses from **Bank** count against daily allowance (unless explicitly marked otherwise)

### Monthly Earmarks
- Mark funds for known monthly expenses (subscriptions, bills, etc.)
- When paid:
  - If actual payment = earmarked amount: Perfect match
  - If actual payment < earmarked amount: Difference returns to Main Savings
  - If actual payment > earmarked amount: Excess deducted from Main Savings

### Transfers
- Withdraw Cash: `Bank → Cash Reserve` (no bucket change)
- Deposit Cash: `Cash Reserve → Bank` (no bucket change)
- Total funds remain constant during transfers

### Corrections
- Apply signed deltas to Bank or Cash when reconciling external changes
- Buckets automatically adjust to match new totals
- All corrections are logged with reasons

## Getting Started

### Requirements
- Xcode 17+ (with iOS 26 SDK)
- iOS 26+ simulator or device

### Build & Run
```bash
# Clone and open
cd Drip
open Drip.xcodeproj

# Build
xcodebuild -project Drip.xcodeproj -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build

# Run tests
xcodebuild test -project Drip.xcodeproj -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

### Load Seed Data
The app includes baseline seed data for testing:
- Bank: $382.19
- Cash Reserve: $3,000.00
- Daily Allowance: $88.41
- Main Savings: $3,382.19

To load: Open Settings → "Load Baseline Seed Data"

## Testing

### Unit Tests (`DripTests/FinanceEngineTests.swift`)
Comprehensive test coverage for business logic:
- ✅ Remaining days calculation
- ✅ Add expense (Bank/Cash)
- ✅ Add income (normal/as savings)
- ✅ Transfers (withdraw/deposit cash)
- ✅ Balance corrections
- ✅ Monthly earmarks (add/pay/difference handling)
- ✅ Custom buckets
- ✅ Auto-reconciliation
- ✅ Remaining daily allowance calculation

Run tests: `⌘+U` in Xcode or use xcodebuild command above.

### Acceptance Scenarios
1. **Seed & Display**: Load baseline → Snapshot matches exact format and sums balance
2. **Expense Tracking**: Add $45 espresso (bank) → Bank reduced, allowance updated, buckets balanced
3. **Transfer**: Withdraw $1000 to cash → Bank -$1000, Cash +$1000, total unchanged
4. **Monthly Earmark**: Add + pay with different amount → Savings adjusted by difference
5. **Correction**: Add $0.42 to bank → Snapshot updates, buckets rebalanced

## File Structure

```
Drip/
├── DripApp.swift                    # App entry point
├── Models/
│   ├── BusinessLogic.swift          # Pure Swift business logic
│   └── FinanceStore.swift           # SwiftData persistence
├── Views/
│   ├── HomeView.swift               # Main screen
│   ├── SnapshotView.swift           # Balance display
│   ├── AddExpenseSheet.swift        # Expense entry with live preview
│   ├── AddIncomeSheet.swift         # Income entry
│   ├── TransferSheet.swift          # Cash ↔ Bank transfers
│   ├── CorrectionsSheet.swift       # Balance corrections
│   ├── BucketsEditorSheet.swift     # Manage earmarks & custom buckets
│   ├── LogsSheet.swift              # View all logs
│   └── SettingsSheet.swift          # App settings & seed data
└── Utilities/
    ├── FormatUtilities.swift        # Formatting helpers
    └── StoicQuotes.swift            # Quote rotation

DripTests/
└── FinanceEngineTests.swift         # Business logic tests
```

## Implementation Notes

### Decimal Precision
All currency values use Swift's `Decimal` type with 2 decimal place precision to avoid floating-point errors.

### Date Handling
- All dates stored as `Date` objects
- Displayed using user locale
- "Remaining days" calculation is **inclusive** of current day

### Snapshot Format
The snapshot follows the exact user-specified format:
```
🟩 Remaining Daily Allowance (today): $XX.XX

Actual Funds:
• 🏦 Bank: $XX.XX
• 💵 Cash Reserve: $XX.XX
• 🔢 Total: $XX.XX

Buckets (must equal Actual Funds):
• 📦 Set-aside (Allowances): $XX.XX (includes today)
• 📦 Set-aside (Monthly): $XX.XX
  – Item Name: $XX.XX
• 🎯 Custom Buckets (Goals): $XX.XX
  – Bucket Name: $XX.XX
• 🛟 Main Savings (Buffer): $XX.XX
• 🔢 Total: $XX.XX

[Stoic Quote]
```

### Stoic Quotes
Six quotes (2 each from Epictetus, Seneca, Marcus Aurelius) rotate daily based on day of year.

## Non-Goals
❌ No remote sync or cloud storage
❌ No user accounts or authentication
❌ No push notifications or background work
❌ No analytics or tracking
❌ No complex charts (logs only)
❌ No third-party dependencies

## Future Enhancements (Not Implemented)
- Export logs to CSV
- Backup/restore functionality
- Multiple currency support
- Recurring expense templates
- Budget vs actual reporting

## License
Production-ready starter project. Use as you wish.

## Credits
Built with SwiftUI and SwiftData for iOS 26+.
Stoic wisdom from Epictetus, Seneca, and Marcus Aurelius.
