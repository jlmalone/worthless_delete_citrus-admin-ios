//
//  User.swift
//  CitrusAdmin
//
//  User model for admin management
//

import Foundation

struct User: Identifiable, Codable, Equatable {
    let id: String
    var email: String
    var name: String
    var role: UserRole
    var isActive: Bool
    var createdAt: Date
    var lastLoginAt: Date?
    var phoneNumber: String?
    var department: String?

    init(
        id: String,
        email: String,
        name: String,
        role: UserRole,
        isActive: Bool,
        createdAt: Date = Date(),
        lastLoginAt: Date? = nil,
        phoneNumber: String? = nil,
        department: String? = nil
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.role = role
        self.isActive = isActive
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
        self.phoneNumber = phoneNumber
        self.department = department
    }
}

enum UserRole: String, Codable, CaseIterable {
    case admin = "Admin"
    case manager = "Manager"
    case user = "User"
    case viewer = "Viewer"

    var permissions: [Permission] {
        switch self {
        case .admin:
            return Permission.allCases
        case .manager:
            return [.viewUsers, .viewReceipts, .reviewReceipts, .viewAnalytics, .viewAlerts]
        case .user:
            return [.viewReceipts, .viewAnalytics, .viewAlerts]
        case .viewer:
            return [.viewReceipts, .viewAnalytics]
        }
    }
}

enum Permission: String, CaseIterable {
    case viewUsers = "View Users"
    case manageUsers = "Manage Users"
    case viewReceipts = "View Receipts"
    case reviewReceipts = "Review Receipts"
    case viewAnalytics = "View Analytics"
    case viewAlerts = "View Alerts"
    case manageAlerts = "Manage Alerts"
}
