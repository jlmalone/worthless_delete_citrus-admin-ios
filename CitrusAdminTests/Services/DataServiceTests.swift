//
//  DataServiceTests.swift
//  CitrusAdminTests
//
//  Unit tests for DataService
//

import XCTest
import Combine
@testable import CitrusAdmin

final class DataServiceTests: XCTestCase {

    var dataService: DataService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        dataService = DataService.shared
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func testDataServiceIsSingleton() {
        // Given
        let instance1 = DataService.shared
        let instance2 = DataService.shared

        // Then
        XCTAssertTrue(instance1 === instance2)
    }

    // MARK: - Fetch Users Tests

    func testFetchUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users")

        // When
        dataService.fetchUsers()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Failed with error: \(error)")
                    }
                },
                receiveValue: { users in
                    // Then
                    XCTAssertFalse(users.isEmpty)
                    XCTAssertGreaterThanOrEqual(users.count, 2)
                    XCTAssertTrue(users.contains(where: { $0.role == .admin }))
                    XCTAssertTrue(users.contains(where: { $0.role == .manager }))
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchUsersReturnsValidData() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch users returns valid data")

        // When
        dataService.fetchUsers()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { users in
                    // Then
                    for user in users {
                        XCTAssertFalse(user.id.isEmpty)
                        XCTAssertFalse(user.email.isEmpty)
                        XCTAssertFalse(user.name.isEmpty)
                        XCTAssertTrue(user.isActive)
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Fetch Receipts Tests

    func testFetchReceipts() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch receipts")

        // When
        dataService.fetchReceipts()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Failed with error: \(error)")
                    }
                },
                receiveValue: { receipts in
                    // Then
                    XCTAssertFalse(receipts.isEmpty)
                    XCTAssertGreaterThanOrEqual(receipts.count, 1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchReceiptsReturnsValidData() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch receipts returns valid data")

        // When
        dataService.fetchReceipts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { receipts in
                    // Then
                    for receipt in receipts {
                        XCTAssertFalse(receipt.id.isEmpty)
                        XCTAssertFalse(receipt.userId.isEmpty)
                        XCTAssertFalse(receipt.merchantName.isEmpty)
                        XCTAssertGreaterThan(receipt.amount, 0)
                        XCTAssertFalse(receipt.currency.isEmpty)
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Fetch Analytics Tests

    func testFetchAnalytics() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch analytics")

        // When
        dataService.fetchAnalytics()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Failed with error: \(error)")
                    }
                },
                receiveValue: { analytics in
                    // Then
                    XCTAssertGreaterThan(analytics.totalReceipts, 0)
                    XCTAssertGreaterThan(analytics.totalAmount, 0)
                    XCTAssertGreaterThan(analytics.activeUsers, 0)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchAnalyticsReturnsConsistentData() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch analytics returns consistent data")

        // When
        dataService.fetchAnalytics()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { analytics in
                    // Then - total should equal sum of statuses
                    let statusSum = analytics.pendingReceipts +
                                  analytics.approvedReceipts +
                                  analytics.rejectedReceipts
                    // Allow for flagged receipts to be part of other statuses
                    XCTAssertLessThanOrEqual(statusSum, analytics.totalReceipts + analytics.flaggedReceipts)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Fetch Alerts Tests

    func testFetchAlerts() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch alerts")

        // When
        dataService.fetchAlerts()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Failed with error: \(error)")
                    }
                },
                receiveValue: { alerts in
                    // Then
                    XCTAssertFalse(alerts.isEmpty)
                    XCTAssertGreaterThanOrEqual(alerts.count, 1)
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    func testFetchAlertsReturnsValidData() {
        // Given
        let expectation = XCTestExpectation(description: "Fetch alerts returns valid data")

        // When
        dataService.fetchAlerts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { alerts in
                    // Then
                    for alert in alerts {
                        XCTAssertFalse(alert.title.isEmpty)
                        XCTAssertFalse(alert.message.isEmpty)
                    }
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Multiple Concurrent Requests Tests

    func testMultipleConcurrentRequests() {
        // Given
        let expectation = XCTestExpectation(description: "Multiple concurrent requests")
        expectation.expectedFulfillmentCount = 4
        var results: [String] = []

        // When
        dataService.fetchUsers()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    results.append("users")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        dataService.fetchReceipts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    results.append("receipts")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        dataService.fetchAnalytics()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    results.append("analytics")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        dataService.fetchAlerts()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    results.append("alerts")
                    expectation.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)

        // Then
        XCTAssertEqual(results.count, 4)
        XCTAssertTrue(results.contains("users"))
        XCTAssertTrue(results.contains("receipts"))
        XCTAssertTrue(results.contains("analytics"))
        XCTAssertTrue(results.contains("alerts"))
    }

    // MARK: - Protocol Conformance Tests

    func testDataServiceConformsToProtocol() {
        // Given
        let service: DataServiceProtocol = DataService.shared

        // Then - should be able to call all protocol methods
        let _ = service.fetchUsers()
        let _ = service.fetchReceipts()
        let _ = service.fetchAnalytics()
        let _ = service.fetchAlerts()
    }

    // MARK: - APIClient Tests

    func testAPIClientIsSingleton() {
        // Given
        let instance1 = APIClient.shared
        let instance2 = APIClient.shared

        // Then
        XCTAssertTrue(instance1 === instance2)
    }

    func testAPIClientRequestWithInvalidURL() {
        // Given
        let expectation = XCTestExpectation(description: "Invalid URL fails")
        let client = APIClient.shared

        // When - attempt to make a request (this will fail since baseURL + endpoint won't return valid data)
        let publisher: AnyPublisher<User, Error> = client.request("/users")

        publisher
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        // Expected to fail since we don't have a real server
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    // Not expected to succeed
                }
            )
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 5.0)
    }
}
