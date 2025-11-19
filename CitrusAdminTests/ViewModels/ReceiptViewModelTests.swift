//
//  ReceiptViewModelTests.swift
//  CitrusAdminTests
//
//  Unit tests for ReceiptViewModel
//

import XCTest
import Combine
@testable import CitrusAdmin

final class ReceiptViewModelTests: XCTestCase {

    var viewModel: ReceiptViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = ReceiptViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertNil(viewModel.selectedStatus)
        XCTAssertNil(viewModel.selectedCategory)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadMockData() {
        // Given
        let expectation = XCTestExpectation(description: "Load mock receipts")

        // When
        viewModel.$receipts
            .dropFirst()
            .sink { receipts in
                // Then
                XCTAssertEqual(receipts.count, 10)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    func testReceiptsAreSortedByDate() {
        // Given
        let expectation = XCTestExpectation(description: "Receipts sorted by date")

        // When
        viewModel.$filteredReceipts
            .dropFirst()
            .sink { receipts in
                // Then - should be sorted newest first
                if receipts.count > 1 {
                    for i in 0..<receipts.count - 1 {
                        XCTAssertTrue(receipts[i].date >= receipts[i + 1].date)
                    }
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Receipt Actions Tests

    func testApproveReceipt() {
        // Given
        let expectation = XCTestExpectation(description: "Approve receipt")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let receipt = self.viewModel.receipts.first(where: { $0.status == .pending })!
            let reviewedBy = "admin-1"

            // When
            self.viewModel.approveReceipt(receipt, reviewedBy: reviewedBy)

            // Then
            let updatedReceipt = self.viewModel.receipts.first(where: { $0.id == receipt.id })
            XCTAssertNotNil(updatedReceipt)
            XCTAssertEqual(updatedReceipt?.status, .approved)
            XCTAssertEqual(updatedReceipt?.reviewedBy, reviewedBy)
            XCTAssertNotNil(updatedReceipt?.reviewedAt)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testRejectReceipt() {
        // Given
        let expectation = XCTestExpectation(description: "Reject receipt")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let receipt = self.viewModel.receipts.first(where: { $0.status == .pending })!
            let reviewedBy = "admin-1"

            // When
            self.viewModel.rejectReceipt(receipt, reviewedBy: reviewedBy)

            // Then
            let updatedReceipt = self.viewModel.receipts.first(where: { $0.id == receipt.id })
            XCTAssertNotNil(updatedReceipt)
            XCTAssertEqual(updatedReceipt?.status, .rejected)
            XCTAssertEqual(updatedReceipt?.reviewedBy, reviewedBy)
            XCTAssertNotNil(updatedReceipt?.reviewedAt)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFlagReceipt() {
        // Given
        let expectation = XCTestExpectation(description: "Flag receipt")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let receipt = self.viewModel.receipts.first(where: { $0.status == .pending })!

            // When
            self.viewModel.flagReceipt(receipt)

            // Then
            let updatedReceipt = self.viewModel.receipts.first(where: { $0.id == receipt.id })
            XCTAssertNotNil(updatedReceipt)
            XCTAssertEqual(updatedReceipt?.status, .flagged)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Count Tests

    func testPendingCount() {
        // Given
        let expectation = XCTestExpectation(description: "Pending count")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            let pendingCount = self.viewModel.pendingCount
            let actualPending = self.viewModel.receipts.filter { $0.status == .pending }.count

            // Then
            XCTAssertEqual(pendingCount, actualPending)
            XCTAssertGreaterThan(pendingCount, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testFlaggedCount() {
        // Given
        let expectation = XCTestExpectation(description: "Flagged count")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            let flaggedCount = self.viewModel.flaggedCount
            let actualFlagged = self.viewModel.receipts.filter { $0.status == .flagged }.count

            // Then
            XCTAssertEqual(flaggedCount, actualFlagged)
            XCTAssertGreaterThan(flaggedCount, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Search and Filter Tests

    func testSearchByMerchantName() {
        // Given
        let expectation = XCTestExpectation(description: "Search by merchant")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "Starbucks"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertFalse(self.viewModel.filteredReceipts.isEmpty)
                XCTAssertTrue(self.viewModel.filteredReceipts.allSatisfy {
                    $0.merchantName.localizedCaseInsensitiveContains("Starbucks")
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testSearchByReceiptId() {
        // Given
        let expectation = XCTestExpectation(description: "Search by receipt ID")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "R001"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertEqual(self.viewModel.filteredReceipts.count, 1)
                XCTAssertEqual(self.viewModel.filteredReceipts.first?.id, "R001")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testFilterByStatus() {
        // Given
        let expectation = XCTestExpectation(description: "Filter by status")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedStatus = .pending

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertFalse(self.viewModel.filteredReceipts.isEmpty)
                XCTAssertTrue(self.viewModel.filteredReceipts.allSatisfy { $0.status == .pending })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testFilterByCategory() {
        // Given
        let expectation = XCTestExpectation(description: "Filter by category")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedCategory = .travel

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertFalse(self.viewModel.filteredReceipts.isEmpty)
                XCTAssertTrue(self.viewModel.filteredReceipts.allSatisfy { $0.category == .travel })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testCombinedFilters() {
        // Given
        let expectation = XCTestExpectation(description: "Combined filters")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedStatus = .approved
            self.viewModel.selectedCategory = .travel

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertTrue(self.viewModel.filteredReceipts.allSatisfy {
                    $0.status == .approved && $0.category == .travel
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testSearchWithFilters() {
        // Given
        let expectation = XCTestExpectation(description: "Search with filters")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "Delta"
            self.viewModel.selectedStatus = .approved
            self.viewModel.selectedCategory = .travel

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertTrue(self.viewModel.filteredReceipts.allSatisfy {
                    $0.merchantName.localizedCaseInsensitiveContains("Delta") &&
                    $0.status == .approved &&
                    $0.category == .travel
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testClearFilters() {
        // Given
        let expectation = XCTestExpectation(description: "Clear filters")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.viewModel.searchText = "Test"
            self.viewModel.selectedStatus = .pending
            self.viewModel.selectedCategory = .meals

            // When
            self.viewModel.searchText = ""
            self.viewModel.selectedStatus = nil
            self.viewModel.selectedCategory = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then - should return all receipts
                XCTAssertEqual(self.viewModel.filteredReceipts.count, self.viewModel.receipts.count)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
