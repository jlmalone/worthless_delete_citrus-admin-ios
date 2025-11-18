//
//  Alert.swift
//  CitrusAdmin
//
//  Alert model for system notifications and warnings
//

import Foundation

struct Alert: Identifiable, Codable {
    let id: String
    var title: String
    var message: String
    var severity: AlertSeverity
    var type: AlertType
    var timestamp: Date
    var isRead: Bool
    var isResolved: Bool
    var relatedReceiptId: String?
    var relatedUserId: String?
    var actionRequired: Bool
    var resolvedBy: String?
    var resolvedAt: Date?

    init(
        id: String = UUID().uuidString,
        title: String,
        message: String,
        severity: AlertSeverity,
        type: AlertType,
        timestamp: Date = Date(),
        isRead: Bool = false,
        isResolved: Bool = false,
        relatedReceiptId: String? = nil,
        relatedUserId: String? = nil,
        actionRequired: Bool = false,
        resolvedBy: String? = nil,
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.severity = severity
        self.type = type
        self.timestamp = timestamp
        self.isRead = isRead
        self.isResolved = isResolved
        self.relatedReceiptId = relatedReceiptId
        self.relatedUserId = relatedUserId
        self.actionRequired = actionRequired
        self.resolvedBy = resolvedBy
        self.resolvedAt = resolvedAt
    }

    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

enum AlertSeverity: String, Codable, CaseIterable {
    case info = "Info"
    case warning = "Warning"
    case error = "Error"
    case critical = "Critical"

    var color: String {
        switch self {
        case .info: return "blue"
        case .warning: return "yellow"
        case .error: return "orange"
        case .critical: return "red"
        }
    }

    var icon: String {
        switch self {
        case .info: return "info.circle"
        case .warning: return "exclamationmark.triangle"
        case .error: return "exclamationmark.circle"
        case .critical: return "exclamationmark.octagon"
        }
    }
}

enum AlertType: String, Codable, CaseIterable {
    case duplicateReceipt = "Duplicate Receipt"
    case highAmount = "High Amount"
    case suspiciousActivity = "Suspicious Activity"
    case systemError = "System Error"
    case userInactive = "User Inactive"
    case pendingReview = "Pending Review"
    case complianceIssue = "Compliance Issue"

    var defaultSeverity: AlertSeverity {
        switch self {
        case .duplicateReceipt: return .warning
        case .highAmount: return .warning
        case .suspiciousActivity: return .error
        case .systemError: return .critical
        case .userInactive: return .info
        case .pendingReview: return .info
        case .complianceIssue: return .error
        }
    }
}
