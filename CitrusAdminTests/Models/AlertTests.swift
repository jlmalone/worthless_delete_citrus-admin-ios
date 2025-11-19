//
//  AlertTests.swift
//  CitrusAdminTests
//
//  Unit tests for Alert model
//

import XCTest
@testable import CitrusAdmin

final class AlertTests: XCTestCase {

    // MARK: - Alert Model Tests

    func testAlertInitialization() {
        // Given
        let title = "Test Alert"
        let message = "This is a test alert"
        let severity = AlertSeverity.warning
        let type = AlertType.highAmount

        // When
        let alert = Alert(
            title: title,
            message: message,
            severity: severity,
            type: type
        )

        // Then
        XCTAssertEqual(alert.title, title)
        XCTAssertEqual(alert.message, message)
        XCTAssertEqual(alert.severity, severity)
        XCTAssertEqual(alert.type, type)
        XCTAssertFalse(alert.isRead)
        XCTAssertFalse(alert.isResolved)
        XCTAssertFalse(alert.actionRequired)
        XCTAssertNil(alert.relatedReceiptId)
        XCTAssertNil(alert.relatedUserId)
        XCTAssertNil(alert.resolvedBy)
        XCTAssertNil(alert.resolvedAt)
        XCTAssertFalse(alert.id.isEmpty)
    }

    func testAlertWithOptionalFields() {
        // Given
        let relatedReceiptId = "R123"
        let relatedUserId = "U456"
        let resolvedBy = "admin-1"
        let resolvedAt = Date()

        // When
        let alert = Alert(
            title: "Test",
            message: "Test message",
            severity: .error,
            type: .suspiciousActivity,
            isRead: true,
            isResolved: true,
            relatedReceiptId: relatedReceiptId,
            relatedUserId: relatedUserId,
            actionRequired: true,
            resolvedBy: resolvedBy,
            resolvedAt: resolvedAt
        )

        // Then
        XCTAssertTrue(alert.isRead)
        XCTAssertTrue(alert.isResolved)
        XCTAssertTrue(alert.actionRequired)
        XCTAssertEqual(alert.relatedReceiptId, relatedReceiptId)
        XCTAssertEqual(alert.relatedUserId, relatedUserId)
        XCTAssertEqual(alert.resolvedBy, resolvedBy)
        XCTAssertEqual(alert.resolvedAt, resolvedAt)
    }

    func testAlertTimeAgo() {
        // Given
        let timestamp = Date().addingTimeInterval(-3600) // 1 hour ago
        let alert = Alert(
            title: "Test",
            message: "Test",
            severity: .info,
            type: .pendingReview,
            timestamp: timestamp
        )

        // When
        let timeAgo = alert.timeAgo

        // Then
        XCTAssertFalse(timeAgo.isEmpty)
        // The exact format depends on locale, but it should contain time information
    }

    func testAlertCodable() throws {
        // Given
        let alert = Alert(
            id: "alert-1",
            title: "Test Alert",
            message: "Test message",
            severity: .critical,
            type: .systemError,
            actionRequired: true
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(alert)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Alert.self, from: data)

        // Then
        XCTAssertEqual(alert.id, decoded.id)
        XCTAssertEqual(alert.title, decoded.title)
        XCTAssertEqual(alert.message, decoded.message)
        XCTAssertEqual(alert.severity, decoded.severity)
        XCTAssertEqual(alert.type, decoded.type)
    }

    // MARK: - AlertSeverity Tests

    func testAlertSeverityColors() {
        XCTAssertEqual(AlertSeverity.info.color, "blue")
        XCTAssertEqual(AlertSeverity.warning.color, "yellow")
        XCTAssertEqual(AlertSeverity.error.color, "orange")
        XCTAssertEqual(AlertSeverity.critical.color, "red")
    }

    func testAlertSeverityIcons() {
        XCTAssertEqual(AlertSeverity.info.icon, "info.circle")
        XCTAssertEqual(AlertSeverity.warning.icon, "exclamationmark.triangle")
        XCTAssertEqual(AlertSeverity.error.icon, "exclamationmark.circle")
        XCTAssertEqual(AlertSeverity.critical.icon, "exclamationmark.octagon")
    }

    func testAlertSeverityRawValues() {
        XCTAssertEqual(AlertSeverity.info.rawValue, "Info")
        XCTAssertEqual(AlertSeverity.warning.rawValue, "Warning")
        XCTAssertEqual(AlertSeverity.error.rawValue, "Error")
        XCTAssertEqual(AlertSeverity.critical.rawValue, "Critical")
    }

    func testAlertSeverityCodable() throws {
        let severities = AlertSeverity.allCases

        for severity in severities {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(severity)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AlertSeverity.self, from: data)

            // Then
            XCTAssertEqual(severity, decoded)
        }
    }

    // MARK: - AlertType Tests

    func testAlertTypeDefaultSeverities() {
        XCTAssertEqual(AlertType.duplicateReceipt.defaultSeverity, .warning)
        XCTAssertEqual(AlertType.highAmount.defaultSeverity, .warning)
        XCTAssertEqual(AlertType.suspiciousActivity.defaultSeverity, .error)
        XCTAssertEqual(AlertType.systemError.defaultSeverity, .critical)
        XCTAssertEqual(AlertType.userInactive.defaultSeverity, .info)
        XCTAssertEqual(AlertType.pendingReview.defaultSeverity, .info)
        XCTAssertEqual(AlertType.complianceIssue.defaultSeverity, .error)
    }

    func testAlertTypeRawValues() {
        XCTAssertEqual(AlertType.duplicateReceipt.rawValue, "Duplicate Receipt")
        XCTAssertEqual(AlertType.highAmount.rawValue, "High Amount")
        XCTAssertEqual(AlertType.suspiciousActivity.rawValue, "Suspicious Activity")
        XCTAssertEqual(AlertType.systemError.rawValue, "System Error")
        XCTAssertEqual(AlertType.userInactive.rawValue, "User Inactive")
        XCTAssertEqual(AlertType.pendingReview.rawValue, "Pending Review")
        XCTAssertEqual(AlertType.complianceIssue.rawValue, "Compliance Issue")
    }

    func testAlertTypeCodable() throws {
        let types = AlertType.allCases

        for type in types {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(type)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(AlertType.self, from: data)

            // Then
            XCTAssertEqual(type, decoded)
        }
    }

    func testAlertTypeCount() {
        XCTAssertEqual(AlertType.allCases.count, 7)
    }

    // MARK: - Integration Tests

    func testAlertWithMatchingSeverity() {
        // Given
        let type = AlertType.systemError

        // When
        let alert = Alert(
            title: "System Error",
            message: "Critical system error",
            severity: type.defaultSeverity,
            type: type
        )

        // Then
        XCTAssertEqual(alert.severity, .critical)
        XCTAssertEqual(alert.type, .systemError)
    }

    func testAlertCanOverrideDefaultSeverity() {
        // Given
        let type = AlertType.userInactive // default is .info

        // When
        let alert = Alert(
            title: "User Inactive",
            message: "Important user is inactive",
            severity: .warning, // override to warning
            type: type
        )

        // Then
        XCTAssertEqual(alert.severity, .warning)
        XCTAssertNotEqual(alert.severity, type.defaultSeverity)
    }
}
