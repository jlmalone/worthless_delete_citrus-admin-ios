//
//  ReceiptTests.swift
//  CitrusAdminTests
//
//  Unit tests for Receipt model
//

import XCTest
@testable import CitrusAdmin

final class ReceiptTests: XCTestCase {

    // MARK: - Receipt Model Tests

    func testReceiptInitialization() {
        // Given
        let id = "R001"
        let userId = "user-123"
        let merchantName = "Test Merchant"
        let amount = 99.99
        let date = Date()
        let category = ReceiptCategory.meals
        let status = ReceiptStatus.pending

        // When
        let receipt = Receipt(
            id: id,
            userId: userId,
            merchantName: merchantName,
            amount: amount,
            date: date,
            category: category,
            status: status
        )

        // Then
        XCTAssertEqual(receipt.id, id)
        XCTAssertEqual(receipt.userId, userId)
        XCTAssertEqual(receipt.merchantName, merchantName)
        XCTAssertEqual(receipt.amount, amount)
        XCTAssertEqual(receipt.currency, "USD")
        XCTAssertEqual(receipt.date, date)
        XCTAssertEqual(receipt.category, category)
        XCTAssertEqual(receipt.status, status)
        XCTAssertNil(receipt.imageUrl)
        XCTAssertNil(receipt.notes)
        XCTAssertNil(receipt.reviewedBy)
        XCTAssertNil(receipt.reviewedAt)
        XCTAssertEqual(receipt.items.count, 0)
    }

    func testReceiptWithOptionalFields() {
        // Given
        let imageUrl = "https://example.com/image.jpg"
        let notes = "Test notes"
        let reviewedBy = "admin-1"
        let reviewedAt = Date()
        let items = [
            ReceiptItem(name: "Item 1", quantity: 2, unitPrice: 10.00, totalPrice: 20.00)
        ]
        let taxAmount = 5.50
        let tipAmount = 10.00

        // When
        let receipt = Receipt(
            id: "R001",
            userId: "1",
            merchantName: "Test",
            amount: 100.00,
            date: Date(),
            category: .meals,
            status: .approved,
            imageUrl: imageUrl,
            notes: notes,
            reviewedBy: reviewedBy,
            reviewedAt: reviewedAt,
            items: items,
            taxAmount: taxAmount,
            tipAmount: tipAmount
        )

        // Then
        XCTAssertEqual(receipt.imageUrl, imageUrl)
        XCTAssertEqual(receipt.notes, notes)
        XCTAssertEqual(receipt.reviewedBy, reviewedBy)
        XCTAssertEqual(receipt.reviewedAt, reviewedAt)
        XCTAssertEqual(receipt.items.count, 1)
        XCTAssertEqual(receipt.taxAmount, taxAmount)
        XCTAssertEqual(receipt.tipAmount, tipAmount)
    }

    func testReceiptFormattedAmount() {
        // Given
        let receipt = Receipt(
            id: "R001",
            userId: "1",
            merchantName: "Test",
            amount: 123.45,
            currency: "USD",
            date: Date(),
            category: .meals,
            status: .pending
        )

        // When
        let formatted = receipt.formattedAmount

        // Then
        XCTAssertTrue(formatted.contains("123.45") || formatted.contains("$123.45"))
    }

    func testReceiptFormattedAmountDifferentCurrency() {
        // Given
        let receipt = Receipt(
            id: "R001",
            userId: "1",
            merchantName: "Test",
            amount: 100.00,
            currency: "EUR",
            date: Date(),
            category: .meals,
            status: .pending
        )

        // When
        let formatted = receipt.formattedAmount

        // Then
        XCTAssertTrue(formatted.contains("100"))
    }

    func testReceiptCodable() throws {
        // Given
        let receipt = Receipt(
            id: "R001",
            userId: "1",
            merchantName: "Test Merchant",
            amount: 99.99,
            date: Date(),
            category: .meals,
            status: .pending,
            notes: "Test notes"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(receipt)
        let decoder = JSONDecoder()
        let decodedReceipt = try decoder.decode(Receipt.self, from: data)

        // Then
        XCTAssertEqual(receipt.id, decodedReceipt.id)
        XCTAssertEqual(receipt.userId, decodedReceipt.userId)
        XCTAssertEqual(receipt.merchantName, decodedReceipt.merchantName)
        XCTAssertEqual(receipt.amount, decodedReceipt.amount)
    }

    // MARK: - ReceiptItem Tests

    func testReceiptItemInitialization() {
        // Given
        let name = "Coffee"
        let quantity = 2
        let unitPrice = 5.50
        let totalPrice = 11.00

        // When
        let item = ReceiptItem(
            name: name,
            quantity: quantity,
            unitPrice: unitPrice,
            totalPrice: totalPrice
        )

        // Then
        XCTAssertEqual(item.name, name)
        XCTAssertEqual(item.quantity, quantity)
        XCTAssertEqual(item.unitPrice, unitPrice)
        XCTAssertEqual(item.totalPrice, totalPrice)
        XCTAssertFalse(item.id.isEmpty)
    }

    func testReceiptItemCodable() throws {
        // Given
        let item = ReceiptItem(
            id: "item-1",
            name: "Test Item",
            quantity: 3,
            unitPrice: 10.00,
            totalPrice: 30.00
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        let decoder = JSONDecoder()
        let decodedItem = try decoder.decode(ReceiptItem.self, from: data)

        // Then
        XCTAssertEqual(item.id, decodedItem.id)
        XCTAssertEqual(item.name, decodedItem.name)
        XCTAssertEqual(item.quantity, decodedItem.quantity)
    }

    // MARK: - ReceiptCategory Tests

    func testReceiptCategoryIcons() {
        XCTAssertEqual(ReceiptCategory.meals.icon, "fork.knife")
        XCTAssertEqual(ReceiptCategory.travel.icon, "airplane")
        XCTAssertEqual(ReceiptCategory.office.icon, "building.2")
        XCTAssertEqual(ReceiptCategory.entertainment.icon, "tv")
        XCTAssertEqual(ReceiptCategory.equipment.icon, "laptopcomputer")
        XCTAssertEqual(ReceiptCategory.other.icon, "tag")
    }

    func testReceiptCategoryRawValues() {
        XCTAssertEqual(ReceiptCategory.meals.rawValue, "Meals")
        XCTAssertEqual(ReceiptCategory.travel.rawValue, "Travel")
        XCTAssertEqual(ReceiptCategory.office.rawValue, "Office")
        XCTAssertEqual(ReceiptCategory.entertainment.rawValue, "Entertainment")
        XCTAssertEqual(ReceiptCategory.equipment.rawValue, "Equipment")
        XCTAssertEqual(ReceiptCategory.other.rawValue, "Other")
    }

    func testReceiptCategoryCodable() throws {
        let categories = ReceiptCategory.allCases

        for category in categories {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(category)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ReceiptCategory.self, from: data)

            // Then
            XCTAssertEqual(category, decoded)
        }
    }

    // MARK: - ReceiptStatus Tests

    func testReceiptStatusColors() {
        XCTAssertEqual(ReceiptStatus.pending.color, "orange")
        XCTAssertEqual(ReceiptStatus.approved.color, "green")
        XCTAssertEqual(ReceiptStatus.rejected.color, "red")
        XCTAssertEqual(ReceiptStatus.flagged.color, "yellow")
    }

    func testReceiptStatusRawValues() {
        XCTAssertEqual(ReceiptStatus.pending.rawValue, "Pending")
        XCTAssertEqual(ReceiptStatus.approved.rawValue, "Approved")
        XCTAssertEqual(ReceiptStatus.rejected.rawValue, "Rejected")
        XCTAssertEqual(ReceiptStatus.flagged.rawValue, "Flagged")
    }

    func testReceiptStatusCodable() throws {
        let statuses = ReceiptStatus.allCases

        for status in statuses {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(status)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ReceiptStatus.self, from: data)

            // Then
            XCTAssertEqual(status, decoded)
        }
    }
}
