//
//  FinanceEngineTests.swift
//  DripTests
//
//  Unit tests for FinanceEngine business logic
//

import XCTest
@testable import Drip

final class FinanceEngineTests: XCTestCase {

    // MARK: - Remaining Days Tests

    func testRemainingDaysInclusive() {
        let calendar = Calendar.current

        // Test with a known date: Sept 30, 2025 (last day of September)
        let components = DateComponents(year: 2025, month: 9, day: 30)
        guard let date = calendar.date(from: components) else {
            XCTFail("Could not create date")
            return
        }

        let remaining = FinanceEngine.remainingDaysInclusive(from: date, calendar: calendar)
        XCTAssertEqual(remaining, 1, "Last day of month should have 1 remaining day inclusive")
    }

    func testRemainingDaysInclusiveFirstDay() {
        let calendar = Calendar.current

        // Test with first day of month
        let components = DateComponents(year: 2025, month: 10, day: 1)
        guard let date = calendar.date(from: components) else {
            XCTFail("Could not create date")
            return
        }

        let remaining = FinanceEngine.remainingDaysInclusive(from: date, calendar: calendar)
        XCTAssertEqual(remaining, 31, "First day of October should have 31 remaining days inclusive")
    }

    // MARK: - Add Expense Tests

    func testAddExpenseFromBank() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        let initialBank = state.bank
        let amount: Decimal = 45.00

        FinanceEngine.addExpense(
            state: &state,
            amount: amount,
            description: "Espresso",
            source: .bank
        )

        XCTAssertEqual(state.bank, initialBank - amount, "Bank should decrease by expense amount")
        XCTAssertEqual(state.cashReserve, 3000.00, "Cash reserve should not change")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    func testAddExpenseFromCash() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        let initialCash = state.cashReserve
        let amount: Decimal = 50.00

        FinanceEngine.addExpense(
            state: &state,
            amount: amount,
            description: "Cash purchase",
            source: .cash
        )

        XCTAssertEqual(state.cashReserve, initialCash - amount, "Cash reserve should decrease by expense amount")
        XCTAssertEqual(state.bank, 382.19, "Bank should not change")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Add Income Tests

    func testAddIncome() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        let initialBank = state.bank
        let amount: Decimal = 500.00

        FinanceEngine.addIncome(
            state: &state,
            amount: amount,
            description: "Freelance work"
        )

        XCTAssertEqual(state.bank, initialBank + amount, "Bank should increase by income amount")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    func testAddIncomeAsSavings() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        let initialMainSavings = state.mainSavings
        let amount: Decimal = 500.00

        FinanceEngine.addIncome(
            state: &state,
            amount: amount,
            description: "Bonus",
            treatAsSavings: true
        )

        XCTAssertEqual(state.mainSavings, initialMainSavings + amount, "Main savings should increase when treating income as savings")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Transfer Tests

    func testWithdrawCash() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        let initialActualFunds = state.actualFunds
        let amount: Decimal = 200.00

        FinanceEngine.withdrawCash(state: &state, amount: amount)

        XCTAssertEqual(state.bank, 800.00, "Bank should decrease by withdrawal amount")
        XCTAssertEqual(state.cashReserve, 700.00, "Cash reserve should increase by withdrawal amount")
        XCTAssertEqual(state.actualFunds, initialActualFunds, "Total funds should not change")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    func testDepositCash() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        let initialActualFunds = state.actualFunds
        let amount: Decimal = 200.00

        FinanceEngine.depositCash(state: &state, amount: amount)

        XCTAssertEqual(state.bank, 1200.00, "Bank should increase by deposit amount")
        XCTAssertEqual(state.cashReserve, 300.00, "Cash reserve should decrease by deposit amount")
        XCTAssertEqual(state.actualFunds, initialActualFunds, "Total funds should not change")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Corrections Tests

    func testApplyCorrection() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        let correction: Decimal = 0.42

        FinanceEngine.applyCorrection(
            state: &state,
            amount: correction,
            description: "Rounding adjustment",
            toAccount: "Bank"
        )

        XCTAssertEqual(state.bank, 382.61, accuracy: 0.01, "Bank should increase by correction amount")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Monthly Earmarks Tests

    func testAddMonthlyEarmark() {
        var state = FinancialState(
            bank: 382.19,
            cashReserve: 3000.00,
            dailyAllowance: 88.41,
            mainSavings: 3382.19
        )

        FinanceEngine.addMonthlyEarmark(
            state: &state,
            name: "Subscription",
            amount: 50.00
        )

        XCTAssertEqual(state.monthlyEarmarks.count, 1)
        XCTAssertEqual(state.setAsideMonthly, 50.00)
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    func testMarkMonthlyEarmarkPaid() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        FinanceEngine.addMonthlyEarmark(state: &state, name: "Subscription", amount: 50.00)

        guard let earmarkId = state.monthlyEarmarks.first?.id else {
            XCTFail("Should have earmark")
            return
        }

        let initialMainSavings = state.mainSavings

        // Pay exact amount
        FinanceEngine.markMonthlyEarmarkPaid(
            state: &state,
            id: earmarkId,
            actualAmountPaid: 50.00,
            paidFrom: .bank
        )

        XCTAssertEqual(state.bank, 950.00, "Bank should decrease by payment")
        XCTAssertTrue(state.monthlyEarmarks.first?.isPaid ?? false, "Earmark should be marked as paid")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    func testMarkMonthlyEarmarkPaidWithDifference() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        FinanceEngine.addMonthlyEarmark(state: &state, name: "Subscription", amount: 50.00)

        guard let earmarkId = state.monthlyEarmarks.first?.id else {
            XCTFail("Should have earmark")
            return
        }

        let initialMainSavings = state.mainSavings

        // Pay less than earmarked
        FinanceEngine.markMonthlyEarmarkPaid(
            state: &state,
            id: earmarkId,
            actualAmountPaid: 45.00,
            paidFrom: .bank
        )

        XCTAssertEqual(state.bank, 955.00, "Bank should decrease by actual payment")
        // Difference (5.00) should go back to mainSavings
        XCTAssertGreaterThan(state.mainSavings, initialMainSavings, "Main savings should increase by difference")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Custom Buckets Tests

    func testAddCustomBucket() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        FinanceEngine.addCustomBucket(state: &state, name: "Vacation Fund", amount: 300.00)

        XCTAssertEqual(state.customBuckets.count, 1)
        XCTAssertEqual(state.customBuckets.first?.name, "Vacation Fund")
        XCTAssertEqual(state.customBuckets.first?.amount, 300.00)
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Reconciliation Tests

    func testAutoFixReconciliation() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        // Manually create a mismatch
        state.mainSavings -= 0.50

        XCTAssertTrue(state.needsReconciliation, "State should need reconciliation")

        FinanceEngine.autoFixReconciliation(state: &state)

        XCTAssertFalse(state.needsReconciliation, "State should not need reconciliation after auto-fix")
        XCTAssertEqual(state.actualFunds, state.totalBuckets, accuracy: 0.01, "Actual funds must equal total buckets")
    }

    // MARK: - Remaining Allowance Tests

    func testRemainingDailyAllowance() {
        var state = FinancialState(
            bank: 1000.00,
            cashReserve: 500.00,
            dailyAllowance: 88.41,
            mainSavings: 1500.00
        )

        let remaining = FinanceEngine.remainingDailyAllowance(state: state)
        XCTAssertEqual(remaining, 88.41, "Should have full allowance when no spending")

        // Add expense
        FinanceEngine.addExpense(state: &state, amount: 45.00, description: "Test", source: .bank)

        let remainingAfter = FinanceEngine.remainingDailyAllowance(state: state)
        XCTAssertEqual(remainingAfter, 43.41, accuracy: 0.01, "Should deduct spent amount from allowance")
    }
}
