//
//  AnalyticsTests.swift
//  CitrusAdminTests
//
//  Unit tests for Analytics models
//

import XCTest
@testable import CitrusAdmin

final class AnalyticsTests: XCTestCase {

    // MARK: - AnalyticsSummary Tests

    func testAnalyticsSummaryInitialization() {
        // Given & When
        let summary = AnalyticsSummary()

        // Then
        XCTAssertEqual(summary.totalReceipts, 0)
        XCTAssertEqual(summary.totalAmount, 0)
        XCTAssertEqual(summary.pendingReceipts, 0)
        XCTAssertEqual(summary.approvedReceipts, 0)
        XCTAssertEqual(summary.rejectedReceipts, 0)
        XCTAssertEqual(summary.flaggedReceipts, 0)
        XCTAssertEqual(summary.activeUsers, 0)
        XCTAssertEqual(summary.averageProcessingTime, 0)
        XCTAssertEqual(summary.topCategories.count, 0)
        XCTAssertEqual(summary.recentActivity.count, 0)
    }

    func testAnalyticsSummaryWithValues() {
        // Given
        let totalReceipts = 100
        let totalAmount = 5000.0
        let pendingReceipts = 20
        let approvedReceipts = 70
        let rejectedReceipts = 10
        let flaggedReceipts = 5
        let activeUsers = 50

        // When
        let summary = AnalyticsSummary(
            totalReceipts: totalReceipts,
            totalAmount: totalAmount,
            pendingReceipts: pendingReceipts,
            approvedReceipts: approvedReceipts,
            rejectedReceipts: rejectedReceipts,
            flaggedReceipts: flaggedReceipts,
            activeUsers: activeUsers
        )

        // Then
        XCTAssertEqual(summary.totalReceipts, totalReceipts)
        XCTAssertEqual(summary.totalAmount, totalAmount)
        XCTAssertEqual(summary.pendingReceipts, pendingReceipts)
        XCTAssertEqual(summary.approvedReceipts, approvedReceipts)
        XCTAssertEqual(summary.rejectedReceipts, rejectedReceipts)
        XCTAssertEqual(summary.flaggedReceipts, flaggedReceipts)
        XCTAssertEqual(summary.activeUsers, activeUsers)
    }

    func testAnalyticsSummaryFormattedAmount() {
        // Given
        let summary = AnalyticsSummary(totalAmount: 12345.67)

        // When
        let formatted = summary.formattedTotalAmount

        // Then
        XCTAssertTrue(formatted.contains("12") || formatted.contains("$12"))
    }

    func testAnalyticsSummaryCodable() throws {
        // Given
        let summary = AnalyticsSummary(
            totalReceipts: 100,
            totalAmount: 5000.0,
            pendingReceipts: 20,
            approvedReceipts: 70,
            rejectedReceipts: 10,
            activeUsers: 50
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(summary)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnalyticsSummary.self, from: data)

        // Then
        XCTAssertEqual(summary.totalReceipts, decoded.totalReceipts)
        XCTAssertEqual(summary.totalAmount, decoded.totalAmount)
        XCTAssertEqual(summary.activeUsers, decoded.activeUsers)
    }

    // MARK: - CategoryAnalytics Tests

    func testCategoryAnalyticsInitialization() {
        // Given
        let category = ReceiptCategory.meals
        let count = 50
        let totalAmount = 1500.0
        let percentage = 30.0

        // When
        let analytics = CategoryAnalytics(
            category: category,
            count: count,
            totalAmount: totalAmount,
            percentage: percentage
        )

        // Then
        XCTAssertEqual(analytics.category, category)
        XCTAssertEqual(analytics.count, count)
        XCTAssertEqual(analytics.totalAmount, totalAmount)
        XCTAssertEqual(analytics.percentage, percentage)
        XCTAssertFalse(analytics.id.isEmpty)
    }

    func testCategoryAnalyticsCodable() throws {
        // Given
        let analytics = CategoryAnalytics(
            id: "cat-1",
            category: .travel,
            count: 100,
            totalAmount: 5000.0,
            percentage: 50.0
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(analytics)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CategoryAnalytics.self, from: data)

        // Then
        XCTAssertEqual(analytics.id, decoded.id)
        XCTAssertEqual(analytics.category, decoded.category)
        XCTAssertEqual(analytics.count, decoded.count)
        XCTAssertEqual(analytics.totalAmount, decoded.totalAmount)
    }

    // MARK: - ActivityItem Tests

    func testActivityItemInitialization() {
        // Given
        let type = ActivityType.receiptSubmitted
        let description = "New receipt submitted"
        let timestamp = Date()
        let userId = "user-123"
        let userName = "John Doe"

        // When
        let activity = ActivityItem(
            type: type,
            description: description,
            timestamp: timestamp,
            userId: userId,
            userName: userName
        )

        // Then
        XCTAssertEqual(activity.type, type)
        XCTAssertEqual(activity.description, description)
        XCTAssertEqual(activity.timestamp, timestamp)
        XCTAssertEqual(activity.userId, userId)
        XCTAssertEqual(activity.userName, userName)
        XCTAssertFalse(activity.id.isEmpty)
    }

    func testActivityItemIcon() {
        // Given
        let activity = ActivityItem(
            type: .receiptApproved,
            description: "Receipt approved",
            timestamp: Date()
        )

        // When
        let icon = activity.icon

        // Then
        XCTAssertEqual(icon, ActivityType.receiptApproved.icon)
        XCTAssertEqual(icon, "checkmark.circle")
    }

    func testActivityItemCodable() throws {
        // Given
        let activity = ActivityItem(
            id: "activity-1",
            type: .userCreated,
            description: "New user created",
            timestamp: Date(),
            userId: "user-1",
            userName: "Test User"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(activity)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ActivityItem.self, from: data)

        // Then
        XCTAssertEqual(activity.id, decoded.id)
        XCTAssertEqual(activity.type, decoded.type)
        XCTAssertEqual(activity.description, decoded.description)
    }

    // MARK: - ActivityType Tests

    func testActivityTypeIcons() {
        XCTAssertEqual(ActivityType.receiptSubmitted.icon, "doc.badge.plus")
        XCTAssertEqual(ActivityType.receiptApproved.icon, "checkmark.circle")
        XCTAssertEqual(ActivityType.receiptRejected.icon, "xmark.circle")
        XCTAssertEqual(ActivityType.userCreated.icon, "person.badge.plus")
        XCTAssertEqual(ActivityType.userUpdated.icon, "person.circle")
        XCTAssertEqual(ActivityType.alertTriggered.icon, "bell.badge")
    }

    func testActivityTypeRawValues() {
        XCTAssertEqual(ActivityType.receiptSubmitted.rawValue, "Receipt Submitted")
        XCTAssertEqual(ActivityType.receiptApproved.rawValue, "Receipt Approved")
        XCTAssertEqual(ActivityType.receiptRejected.rawValue, "Receipt Rejected")
        XCTAssertEqual(ActivityType.userCreated.rawValue, "User Created")
        XCTAssertEqual(ActivityType.userUpdated.rawValue, "User Updated")
        XCTAssertEqual(ActivityType.alertTriggered.rawValue, "Alert Triggered")
    }

    func testActivityTypeCodable() throws {
        let types: [ActivityType] = [
            .receiptSubmitted, .receiptApproved, .receiptRejected,
            .userCreated, .userUpdated, .alertTriggered
        ]

        for type in types {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(type)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ActivityType.self, from: data)

            // Then
            XCTAssertEqual(type, decoded)
        }
    }

    // MARK: - ChartData Tests

    func testChartDataInitialization() {
        // Given
        let label = "Test Label"
        let value = 100.0
        let color = "blue"

        // When
        let chartData = ChartData(label: label, value: value, color: color)

        // Then
        XCTAssertEqual(chartData.label, label)
        XCTAssertEqual(chartData.value, value)
        XCTAssertEqual(chartData.color, color)
        XCTAssertNotNil(chartData.id)
    }
}
