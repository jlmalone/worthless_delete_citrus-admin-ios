//
//  UserTests.swift
//  CitrusAdminTests
//
//  Unit tests for User model
//

import XCTest
@testable import CitrusAdmin

final class UserTests: XCTestCase {

    // MARK: - User Model Tests

    func testUserInitialization() {
        // Given
        let id = "test-123"
        let email = "test@citrus.com"
        let name = "Test User"
        let role = UserRole.admin
        let isActive = true
        let createdAt = Date()

        // When
        let user = User(
            id: id,
            email: email,
            name: name,
            role: role,
            isActive: isActive,
            createdAt: createdAt
        )

        // Then
        XCTAssertEqual(user.id, id)
        XCTAssertEqual(user.email, email)
        XCTAssertEqual(user.name, name)
        XCTAssertEqual(user.role, role)
        XCTAssertEqual(user.isActive, isActive)
        XCTAssertEqual(user.createdAt, createdAt)
        XCTAssertNil(user.lastLoginAt)
        XCTAssertNil(user.phoneNumber)
        XCTAssertNil(user.department)
    }

    func testUserWithOptionalFields() {
        // Given
        let phoneNumber = "+1234567890"
        let department = "Engineering"
        let lastLoginAt = Date()

        // When
        let user = User(
            id: "1",
            email: "test@citrus.com",
            name: "Test",
            role: .user,
            isActive: true,
            lastLoginAt: lastLoginAt,
            phoneNumber: phoneNumber,
            department: department
        )

        // Then
        XCTAssertEqual(user.phoneNumber, phoneNumber)
        XCTAssertEqual(user.department, department)
        XCTAssertEqual(user.lastLoginAt, lastLoginAt)
    }

    func testUserEquality() {
        // Given
        let user1 = User(id: "1", email: "test@citrus.com", name: "Test", role: .admin, isActive: true)
        let user2 = User(id: "1", email: "test@citrus.com", name: "Test", role: .admin, isActive: true)
        let user3 = User(id: "2", email: "test2@citrus.com", name: "Test2", role: .user, isActive: false)

        // Then
        XCTAssertEqual(user1, user2)
        XCTAssertNotEqual(user1, user3)
    }

    func testUserCodable() throws {
        // Given
        let user = User(
            id: "1",
            email: "test@citrus.com",
            name: "Test User",
            role: .manager,
            isActive: true,
            phoneNumber: "+1234567890"
        )

        // When
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        let decoder = JSONDecoder()
        let decodedUser = try decoder.decode(User.self, from: data)

        // Then
        XCTAssertEqual(user, decodedUser)
    }

    // MARK: - UserRole Tests

    func testAdminPermissions() {
        // Given
        let role = UserRole.admin

        // Then
        XCTAssertEqual(role.permissions.count, Permission.allCases.count)
        XCTAssertTrue(role.permissions.contains(.manageUsers))
        XCTAssertTrue(role.permissions.contains(.viewUsers))
        XCTAssertTrue(role.permissions.contains(.reviewReceipts))
    }

    func testManagerPermissions() {
        // Given
        let role = UserRole.manager

        // Then
        XCTAssertTrue(role.permissions.contains(.viewUsers))
        XCTAssertTrue(role.permissions.contains(.viewReceipts))
        XCTAssertTrue(role.permissions.contains(.reviewReceipts))
        XCTAssertTrue(role.permissions.contains(.viewAnalytics))
        XCTAssertTrue(role.permissions.contains(.viewAlerts))
        XCTAssertFalse(role.permissions.contains(.manageUsers))
        XCTAssertFalse(role.permissions.contains(.manageAlerts))
    }

    func testUserPermissions() {
        // Given
        let role = UserRole.user

        // Then
        XCTAssertTrue(role.permissions.contains(.viewReceipts))
        XCTAssertTrue(role.permissions.contains(.viewAnalytics))
        XCTAssertTrue(role.permissions.contains(.viewAlerts))
        XCTAssertFalse(role.permissions.contains(.viewUsers))
        XCTAssertFalse(role.permissions.contains(.manageUsers))
        XCTAssertFalse(role.permissions.contains(.reviewReceipts))
    }

    func testViewerPermissions() {
        // Given
        let role = UserRole.viewer

        // Then
        XCTAssertTrue(role.permissions.contains(.viewReceipts))
        XCTAssertTrue(role.permissions.contains(.viewAnalytics))
        XCTAssertFalse(role.permissions.contains(.viewAlerts))
        XCTAssertFalse(role.permissions.contains(.viewUsers))
        XCTAssertFalse(role.permissions.contains(.reviewReceipts))
    }

    func testUserRoleCodable() throws {
        // Given
        let roles: [UserRole] = [.admin, .manager, .user, .viewer]

        for role in roles {
            // When
            let encoder = JSONEncoder()
            let data = try encoder.encode(role)
            let decoder = JSONDecoder()
            let decodedRole = try decoder.decode(UserRole.self, from: data)

            // Then
            XCTAssertEqual(role, decodedRole)
        }
    }

    func testUserRoleRawValues() {
        XCTAssertEqual(UserRole.admin.rawValue, "Admin")
        XCTAssertEqual(UserRole.manager.rawValue, "Manager")
        XCTAssertEqual(UserRole.user.rawValue, "User")
        XCTAssertEqual(UserRole.viewer.rawValue, "Viewer")
    }

    func testPermissionCaseCount() {
        XCTAssertEqual(Permission.allCases.count, 7)
    }
}
