//
//  UserViewModelTests.swift
//  CitrusAdminTests
//
//  Unit tests for UserViewModel
//

import XCTest
import Combine
@testable import CitrusAdmin

final class UserViewModelTests: XCTestCase {

    var viewModel: UserViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = UserViewModel()
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialState() {
        // Then
        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertNil(viewModel.selectedRole)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadMockData() {
        // Given
        let expectation = XCTestExpectation(description: "Load mock data")

        // When
        viewModel.$users
            .dropFirst() // Skip initial empty state
            .sink { users in
                // Then
                XCTAssertFalse(users.isEmpty)
                XCTAssertEqual(users.count, 8)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)
    }

    func testLoadingState() {
        // Given
        let expectation = XCTestExpectation(description: "Loading state changes")
        var loadingStates: [Bool] = []

        // When
        viewModel.$isLoading
            .sink { isLoading in
                loadingStates.append(isLoading)
                if loadingStates.count == 3 { // initial false, true, false
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.loadMockData()

        wait(for: [expectation], timeout: 2.0)

        // Then
        XCTAssertEqual(loadingStates[0], false) // initial
        XCTAssertEqual(loadingStates[1], true)  // loading
        XCTAssertEqual(loadingStates[2], false) // done
    }

    // MARK: - User Management Tests

    func testCreateUser() {
        // Given
        let expectation = XCTestExpectation(description: "Create user")
        viewModel.loadMockData()

        // Wait for initial load
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let initialCount = self.viewModel.users.count
            let newUser = User(
                id: "999",
                email: "new@citrus.com",
                name: "New User",
                role: .user,
                isActive: true
            )

            // When
            self.viewModel.createUser(newUser)

            // Then
            XCTAssertEqual(self.viewModel.users.count, initialCount + 1)
            XCTAssertTrue(self.viewModel.users.contains(where: { $0.id == "999" }))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testUpdateUser() {
        // Given
        let expectation = XCTestExpectation(description: "Update user")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            var userToUpdate = self.viewModel.users.first!
            let originalEmail = userToUpdate.email
            userToUpdate.email = "updated@citrus.com"

            // When
            self.viewModel.updateUser(userToUpdate)

            // Then
            let updatedUser = self.viewModel.users.first(where: { $0.id == userToUpdate.id })
            XCTAssertNotNil(updatedUser)
            XCTAssertEqual(updatedUser?.email, "updated@citrus.com")
            XCTAssertNotEqual(updatedUser?.email, originalEmail)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testDeleteUser() {
        // Given
        let expectation = XCTestExpectation(description: "Delete user")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let userToDelete = self.viewModel.users.first!
            let initialCount = self.viewModel.users.count

            // When
            self.viewModel.deleteUser(userToDelete)

            // Then
            XCTAssertEqual(self.viewModel.users.count, initialCount - 1)
            XCTAssertFalse(self.viewModel.users.contains(where: { $0.id == userToDelete.id }))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testToggleUserStatus() {
        // Given
        let expectation = XCTestExpectation(description: "Toggle user status")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let user = self.viewModel.users.first!
            let originalStatus = user.isActive

            // When
            self.viewModel.toggleUserStatus(user)

            // Then
            let updatedUser = self.viewModel.users.first(where: { $0.id == user.id })
            XCTAssertNotNil(updatedUser)
            XCTAssertEqual(updatedUser?.isActive, !originalStatus)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Search and Filter Tests

    func testSearchByName() {
        // Given
        let expectation = XCTestExpectation(description: "Search by name")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "John"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertTrue(self.viewModel.filteredUsers.allSatisfy {
                    $0.name.localizedCaseInsensitiveContains("John")
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testSearchByEmail() {
        // Given
        let expectation = XCTestExpectation(description: "Search by email")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "citrus.com"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertFalse(self.viewModel.filteredUsers.isEmpty)
                XCTAssertTrue(self.viewModel.filteredUsers.allSatisfy {
                    $0.email.localizedCaseInsensitiveContains("citrus.com")
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testFilterByRole() {
        // Given
        let expectation = XCTestExpectation(description: "Filter by role")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.selectedRole = .admin

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertFalse(self.viewModel.filteredUsers.isEmpty)
                XCTAssertTrue(self.viewModel.filteredUsers.allSatisfy { $0.role == .admin })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testSearchAndFilterCombined() {
        // Given
        let expectation = XCTestExpectation(description: "Search and filter combined")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "John"
            self.viewModel.selectedRole = .admin

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then - Should find John Doe who is an admin
                XCTAssertFalse(self.viewModel.filteredUsers.isEmpty)
                XCTAssertTrue(self.viewModel.filteredUsers.allSatisfy {
                    $0.name.localizedCaseInsensitiveContains("John") && $0.role == .admin
                })
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testEmptySearchReturnsAllUsers() {
        // Given
        let expectation = XCTestExpectation(description: "Empty search returns all")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let totalUsers = self.viewModel.users.count

            // When
            self.viewModel.searchText = ""
            self.viewModel.selectedRole = nil

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then
                XCTAssertEqual(self.viewModel.filteredUsers.count, totalUsers)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testCaseInsensitiveSearch() {
        // Given
        let expectation = XCTestExpectation(description: "Case insensitive search")
        viewModel.loadMockData()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // When
            self.viewModel.searchText = "JOHN"

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                // Then - Should still find "John"
                XCTAssertTrue(self.viewModel.filteredUsers.contains(where: {
                    $0.name.localizedCaseInsensitiveContains("john")
                }))
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
