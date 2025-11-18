//
//  Analytics.swift
//  CitrusAdmin
//
//  Analytics models for dashboard metrics
//

import Foundation

struct AnalyticsSummary: Codable {
    var totalReceipts: Int
    var totalAmount: Double
    var pendingReceipts: Int
    var approvedReceipts: Int
    var rejectedReceipts: Int
    var flaggedReceipts: Int
    var activeUsers: Int
    var averageProcessingTime: TimeInterval
    var topCategories: [CategoryAnalytics]
    var recentActivity: [ActivityItem]

    init(
        totalReceipts: Int = 0,
        totalAmount: Double = 0,
        pendingReceipts: Int = 0,
        approvedReceipts: Int = 0,
        rejectedReceipts: Int = 0,
        flaggedReceipts: Int = 0,
        activeUsers: Int = 0,
        averageProcessingTime: TimeInterval = 0,
        topCategories: [CategoryAnalytics] = [],
        recentActivity: [ActivityItem] = []
    ) {
        self.totalReceipts = totalReceipts
        self.totalAmount = totalAmount
        self.pendingReceipts = pendingReceipts
        self.approvedReceipts = approvedReceipts
        self.rejectedReceipts = rejectedReceipts
        self.flaggedReceipts = flaggedReceipts
        self.activeUsers = activeUsers
        self.averageProcessingTime = averageProcessingTime
        self.topCategories = topCategories
        self.recentActivity = recentActivity
    }

    var formattedTotalAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalAmount)) ?? "$\(totalAmount)"
    }
}

struct CategoryAnalytics: Identifiable, Codable {
    let id: String
    var category: ReceiptCategory
    var count: Int
    var totalAmount: Double
    var percentage: Double

    init(id: String = UUID().uuidString, category: ReceiptCategory, count: Int, totalAmount: Double, percentage: Double) {
        self.id = id
        self.category = category
        self.count = count
        self.totalAmount = totalAmount
        self.percentage = percentage
    }
}

struct ActivityItem: Identifiable, Codable {
    let id: String
    var type: ActivityType
    var description: String
    var timestamp: Date
    var userId: String?
    var userName: String?

    init(id: String = UUID().uuidString, type: ActivityType, description: String, timestamp: Date, userId: String? = nil, userName: String? = nil) {
        self.id = id
        self.type = type
        self.description = description
        self.timestamp = timestamp
        self.userId = userId
        self.userName = userName
    }

    var icon: String {
        type.icon
    }
}

enum ActivityType: String, Codable {
    case receiptSubmitted = "Receipt Submitted"
    case receiptApproved = "Receipt Approved"
    case receiptRejected = "Receipt Rejected"
    case userCreated = "User Created"
    case userUpdated = "User Updated"
    case alertTriggered = "Alert Triggered"

    var icon: String {
        switch self {
        case .receiptSubmitted: return "doc.badge.plus"
        case .receiptApproved: return "checkmark.circle"
        case .receiptRejected: return "xmark.circle"
        case .userCreated: return "person.badge.plus"
        case .userUpdated: return "person.circle"
        case .alertTriggered: return "bell.badge"
        }
    }
}

struct ChartData: Identifiable {
    let id = UUID()
    var label: String
    var value: Double
    var color: String
}
