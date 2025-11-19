//
//  AlertViewModelTests.swift
//  CitrusAdminTests
//
//  Unit tests for AlertViewModel
//

import XCTest
import Combine
@testable import CitrusAdmin

final class AlertViewModelTests: XCTestCase {

    var viewModel: AlertViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = AlertViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertNil(viewModel.selectedSeverity)
        XCTAssertFalse(viewModel.showResolved)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadMockData() {
        // Given
        let expectation = XCTestExpectation(description: "Load mock alerts")

        // When
        viewModel.$alerts
            .dropFirst()
            .sink { alerts in
                // Then
                XCTAssertEqual(alerts.count, 8)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    func testFilteredAlertsExcludeResolved() {
        // Given
        let expectation = XCTestExpectation(description: "Filtered alerts exclude resolved")

        // When
        viewModel.$filteredAlerts
            .dropFirst()
            .sink { alerts in
                // Then - by default, resolved alerts should be excluded
                XCTAssertTrue(alerts.allSatisfy { !$0.isResolved })
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    func testAlertsSortedByTimestamp() {
        // Given
        let expectation = XCTestExpectation(description: "Alerts sorted by timestamp")

        // When
        viewModel.$filteredAlerts
            .dropFirst()
            .sink { alerts in
                // Then - should be sorted newest first
                if alerts.count > 1 {
                    for i in 0..<alerts.count - 1 {
                        XCTAssertTrue(alerts[i].timestamp >= alerts[i + 1].timestamp)
                    }
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Alert Actions Tests

    func testMarkAsRead() {
        // Given
        let expectation = XCTestExpectation(description: "Mark alert as read")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = self.viewModel.alerts.first(where: { !$0.isRead })!
            XCTAssertFalse(alert.isRead)

            // When
            self.viewModel.markAsRead(alert)

            // Then
            let updatedAlert = self.viewModel.alerts.first(where: { $0.id == alert.id })
            XCTAssertNotNil(updatedAlert)
            XCTAssertTrue(updatedAlert!.isRead)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testResolveAlert() {
        // Given
        let expectation = XCTestExpectation(description: "Resolve alert")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = self.viewModel.alerts.first(where: { !$0.isResolved })!
            let resolvedBy = "admin-1"

            // When
            self.viewModel.resolveAlert(alert, resolvedBy: resolvedBy)

            // Then
            let updatedAlert = self.viewModel.alerts.first(where: { $0.id == alert.id })
            XCTAssertNotNil(updatedAlert)
            XCTAssertTrue(updatedAlert!.isResolved)
            XCTAssertEqual(updatedAlert!.resolvedBy, resolvedBy)
            XCTAssertNotNil(updatedAlert!.resolvedAt)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testResolvedAlertNotInFilteredList() {
        // Given
        let expectation = XCTestExpectation(description: "Resolved alert filtered out")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = self.viewModel.filteredAlerts.first!
            let alertId = alert.id

            // When
            self.viewModel.resolveAlert(alert, resolvedBy: "admin-1")

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then - alert should not be in filtered list (showResolved = false)
                XCTAssertFalse(self.viewModel.filteredAlerts.contains(where: { $0.id == alertId }))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Filter Tests

    func testFilterBySeverity() {
        // Given
        let expectation = XCTestExpectation(description: "Filter by severity")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedSeverity = .critical

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertTrue(self.viewModel.filteredAlerts.allSatisfy { $0.severity == .critical })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testShowResolvedAlerts() {
        // Given
        let expectation = XCTestExpectation(description: "Show resolved alerts")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let totalAlerts = self.viewModel.alerts.count

            // When
            self.viewModel.showResolved = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then - should include resolved alerts
                XCTAssertEqual(self.viewModel.filteredAlerts.count, totalAlerts)
                XCTAssertTrue(self.viewModel.filteredAlerts.contains(where: { $0.isResolved }))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testCombinedFilters() {
        // Given
        let expectation = XCTestExpectation(description: "Combined filters")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedSeverity = .warning
            self.viewModel.showResolved = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Then
                XCTAssertTrue(self.viewModel.filteredAlerts.allSatisfy { $0.severity == .warning })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Count Tests

    func testUnreadCount() {
        // Given
        let expectation = XCTestExpectation(description: "Unread count")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            let unreadCount = self.viewModel.unreadCount
            let actualUnread = self.viewModel.alerts.filter { !$0.isRead && !$0.isResolved }.count

            // Then
            XCTAssertEqual(unreadCount, actualUnread)
            XCTAssertGreaterThan(unreadCount, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testCriticalCount() {
        // Given
        let expectation = XCTestExpectation(description: "Critical count")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            let criticalCount = self.viewModel.criticalCount
            let actualCritical = self.viewModel.alerts.filter {
                $0.severity == .critical && !$0.isResolved
            }.count

            // Then
            XCTAssertEqual(criticalCount, actualCritical)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testActionRequiredCount() {
        // Given
        let expectation = XCTestExpectation(description: "Action required count")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            let actionRequiredCount = self.viewModel.actionRequiredCount
            let actualActionRequired = self.viewModel.alerts.filter {
                $0.actionRequired && !$0.isResolved
            }.count

            // Then
            XCTAssertEqual(actionRequiredCount, actualActionRequired)
            XCTAssertGreaterThan(actionRequiredCount, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testUnreadCountAfterMarkingAsRead() {
        // Given
        let expectation = XCTestExpectation(description: "Unread count decreases")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let initialUnreadCount = self.viewModel.unreadCount
            let alert = self.viewModel.alerts.first(where: { !$0.isRead && !$0.isResolved })!

            // When
            self.viewModel.markAsRead(alert)

            // Then
            XCTAssertEqual(self.viewModel.unreadCount, initialUnreadCount - 1)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testActionRequiredCountAfterResolving() {
        // Given
        let expectation = XCTestExpectation(description: "Action required count decreases")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let initialCount = self.viewModel.actionRequiredCount
            let alert = self.viewModel.alerts.first(where: {
                $0.actionRequired && !$0.isResolved
            })!

            // When
            self.viewModel.resolveAlert(alert, resolvedBy: "admin-1")

            // Then
            XCTAssertEqual(self.viewModel.actionRequiredCount, initialCount - 1)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
