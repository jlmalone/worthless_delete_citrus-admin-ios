//
//  AnalyticsViewModelTests.swift
//  CitrusAdminTests
//
//  Unit tests for AnalyticsViewModel
//

import XCTest
import Combine
@testable import CitrusAdmin

final class AnalyticsViewModelTests: XCTestCase {

    var viewModel: AnalyticsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = AnalyticsViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.selectedTimeRange, .thisMonth)
    }

    func testLoadAnalytics() {
        // Given
        let expectation = XCTestExpectation(description: "Load analytics")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { summary in
                // Then
                XCTAssertGreaterThan(summary.totalReceipts, 0)
                XCTAssertGreaterThan(summary.totalAmount, 0)
                XCTAssertGreaterThan(summary.activeUsers, 0)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []

        // When
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 { // initial false, true, false
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(loadingStates[0], false) // initial
        XCTAssertEqual(loadingStates[1], true)  // loading
        XCTAssertEqual(loadingStates[2], false) // done
    }

    // MARK: - Summary Data Tests

    func testSummaryHasExpectedData() {
        // Given
        let expectation = XCTestExpectation(description: "Summary has data")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { summary in
                // Then
                XCTAssertEqual(summary.totalReceipts, 847)
                XCTAssertEqual(summary.totalAmount, 125_430.50, accuracy: 0.01)
                XCTAssertEqual(summary.pendingReceipts, 23)
                XCTAssertEqual(summary.approvedReceipts, 782)
                XCTAssertEqual(summary.rejectedReceipts, 34)
                XCTAssertEqual(summary.flaggedReceipts, 8)
                XCTAssertEqual(summary.activeUsers, 142)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testSummaryHasTopCategories() {
        // Given
        let expectation = XCTestExpectation(description: "Summary has top categories")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { summary in
                // Then
                XCTAssertEqual(summary.topCategories.count, 5)
                XCTAssertEqual(summary.topCategories[0].category, .travel)
                XCTAssertEqual(summary.topCategories[1].category, .meals)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testSummaryHasRecentActivity() {
        // Given
        let expectation = XCTestExpectation(description: "Summary has recent activity")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { summary in
                // Then
                XCTAssertEqual(summary.recentActivity.count, 6)
                XCTAssertEqual(summary.recentActivity[0].type, .receiptSubmitted)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Computed Properties Tests

    func testApprovalRate() {
        // Given
        let expectation = XCTestExpectation(description: "Approval rate calculation")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { _ in
                // Then
                let rate = self.viewModel.approvalRate
                let expectedRate = Double(782) / Double(847) * 100
                XCTAssertEqual(rate, expectedRate, accuracy: 0.01)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testRejectionRate() {
        // Given
        let expectation = XCTestExpectation(description: "Rejection rate calculation")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { _ in
                // Then
                let rate = self.viewModel.rejectionRate
                let expectedRate = Double(34) / Double(847) * 100
                XCTAssertEqual(rate, expectedRate, accuracy: 0.01)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testPendingRate() {
        // Given
        let expectation = XCTestExpectation(description: "Pending rate calculation")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { _ in
                // Then
                let rate = self.viewModel.pendingRate
                let expectedRate = Double(23) / Double(847) * 100
                XCTAssertEqual(rate, expectedRate, accuracy: 0.01)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    func testApprovalRateWithZeroReceipts() {
        // Given
        viewModel.summary = AnalyticsSummary(totalReceipts: 0)

        // When
        let rate = viewModel.approvalRate

        // Then
        XCTAssertEqual(rate, 0)
    }

    func testChartData() {
        // Given
        let expectation = XCTestExpectation(description: "Chart data")

        // When
        viewModel.$summary
            .dropFirst()
            .sink { _ in
                // Then
                let chartData = self.viewModel.chartData
                XCTAssertEqual(chartData.count, 4)

                XCTAssertEqual(chartData[0].label, "Approved")
                XCTAssertEqual(chartData[0].value, 782)
                XCTAssertEqual(chartData[0].color, "green")

                XCTAssertEqual(chartData[1].label, "Pending")
                XCTAssertEqual(chartData[1].value, 23)
                XCTAssertEqual(chartData[1].color, "orange")

                XCTAssertEqual(chartData[2].label, "Rejected")
                XCTAssertEqual(chartData[2].value, 34)
                XCTAssertEqual(chartData[2].color, "red")

                XCTAssertEqual(chartData[3].label, "Flagged")
                XCTAssertEqual(chartData[3].value, 8)
                XCTAssertEqual(chartData[3].color, "yellow")

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Refresh Tests

    func testRefreshAnalytics() {
        // Given
        let expectation = XCTestExpectation(description: "Refresh analytics")
        expectation.expectedFulfillmentCount = 2 // initial load + refresh

        viewModel.$summary
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadAnalytics()

        // When
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.viewModel.refreshAnalytics()
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - TimeRange Tests

    func testTimeRangeSelection() {
        // Given
        let ranges = TimeRange.allCases

        // When/Then
        for range in ranges {
            viewModel.selectedTimeRange = range
            XCTAssertEqual(viewModel.selectedTimeRange, range)
        }
    }

    func testTimeRangeValues() {
        XCTAssertEqual(TimeRange.today.rawValue, "Today")
        XCTAssertEqual(TimeRange.thisWeek.rawValue, "This Week")
        XCTAssertEqual(TimeRange.thisMonth.rawValue, "This Month")
        XCTAssertEqual(TimeRange.thisYear.rawValue, "This Year")
    }

    func testAllTimeRangesExist() {
        XCTAssertEqual(TimeRange.allCases.count, 4)
    }
}
