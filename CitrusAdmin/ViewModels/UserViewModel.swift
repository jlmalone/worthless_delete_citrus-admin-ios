//
//  UserViewModel.swift
//  CitrusAdmin
//
//  ViewModel for user management using Combine
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var filteredUsers: [User] = []
    @Published var searchText: String = ""
    @Published var selectedRole: UserRole?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockData()
        setupSearchAndFilter()
    }

    private func setupSearchAndFilter() {
        Publishers.CombineLatest($searchText, $selectedRole)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, role in
                self?.filterUsers(searchText: searchText, role: role)
            }
            .store(in: &cancellables)
    }

    private func filterUsers(searchText: String, role: UserRole?) {
        var filtered = users

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.email.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let role = role {
            filtered = filtered.filter { $0.role == role }
        }

        filteredUsers = filtered
    }

    func loadMockData() {
        isLoading = true

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.users = [
                User(id: "1", email: "john.doe@citrus.com", name: "John Doe", role: .admin, isActive: true, department: "Engineering"),
                User(id: "2", email: "jane.smith@citrus.com", name: "Jane Smith", role: .manager, isActive: true, department: "Finance"),
                User(id: "3", email: "bob.johnson@citrus.com", name: "Bob Johnson", role: .user, isActive: true, department: "Sales"),
                User(id: "4", email: "alice.williams@citrus.com", name: "Alice Williams", role: .manager, isActive: true, department: "Marketing"),
                User(id: "5", email: "charlie.brown@citrus.com", name: "Charlie Brown", role: .user, isActive: false, department: "Support"),
                User(id: "6", email: "diana.prince@citrus.com", name: "Diana Prince", role: .viewer, isActive: true, department: "HR"),
                User(id: "7", email: "evan.davis@citrus.com", name: "Evan Davis", role: .user, isActive: true, department: "Operations"),
                User(id: "8", email: "fiona.miller@citrus.com", name: "Fiona Miller", role: .admin, isActive: true, department: "Engineering")
            ]
            self?.filteredUsers = self?.users ?? []
            self?.isLoading = false
        }
    }

    func createUser(_ user: User) {
        users.append(user)
        filterUsers(searchText: searchText, role: selectedRole)
    }

    func updateUser(_ user: User) {
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
            filterUsers(searchText: searchText, role: selectedRole)
        }
    }

    func deleteUser(_ user: User) {
        users.removeAll { $0.id == user.id }
        filterUsers(searchText: searchText, role: selectedRole)
    }

    func toggleUserStatus(_ user: User) {
        var updatedUser = user
        updatedUser.isActive.toggle()
        updateUser(updatedUser)
    }
}
