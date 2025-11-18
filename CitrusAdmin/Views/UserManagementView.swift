//
//  UserManagementView.swift
//  CitrusAdmin
//
//  User management view for admin operations
//

import SwiftUI

struct UserManagementView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var showingAddUser = false
    @State private var selectedUser: User?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search users...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedRole == nil,
                                action: { viewModel.selectedRole = nil }
                            )
                            ForEach(UserRole.allCases, id: \.self) { role in
                                FilterChip(
                                    title: role.rawValue,
                                    isSelected: viewModel.selectedRole == role,
                                    action: { viewModel.selectedRole = role }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                Divider()

                // User List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredUsers) { user in
                            UserRow(user: user)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedUser = user
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Users (\(viewModel.filteredUsers.count))")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddUser = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(viewModel: viewModel)
            }
            .sheet(item: $selectedUser) { user in
                UserDetailView(user: user, viewModel: viewModel)
            }
        }
    }
}

struct UserRow: View {
    let user: User

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            Circle()
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.orange, .red]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .frame(width: 50, height: 50)
                .overlay(
                    Text(user.name.prefix(1).uppercased())
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack {
                    RoleBadge(role: user.role)
                    if user.department != nil {
                        Text(user.department!)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // Status indicator
            Circle()
                .fill(user.isActive ? Color.green : Color.gray)
                .frame(width: 10, height: 10)
        }
        .padding(.vertical, 8)
    }
}

struct RoleBadge: View {
    let role: UserRole

    var body: some View {
        Text(role.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(roleColor.opacity(0.2))
            .foregroundColor(roleColor)
            .cornerRadius(6)
    }

    var roleColor: Color {
        switch role {
        case .admin: return .red
        case .manager: return .blue
        case .user: return .green
        case .viewer: return .gray
        }
    }
}

struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserViewModel

    @State private var name = ""
    @State private var email = ""
    @State private var role: UserRole = .user
    @State private var department = ""
    @State private var phoneNumber = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("User Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Department", text: $department)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Role")) {
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases, id: \.self) { role in
                            Text(role.rawValue).tag(role)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Permissions")) {
                    ForEach(role.permissions, id: \.self) { permission in
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text(permission.rawValue)
                        }
                    }
                }
            }
            .navigationTitle("Add User")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let user = User(
                            id: UUID().uuidString,
                            email: email,
                            name: name,
                            role: role,
                            isActive: true,
                            department: department.isEmpty ? nil : department,
                            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber
                        )
                        viewModel.createUser(user)
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct UserDetailView: View {
    let user: User
    @ObservedObject var viewModel: UserViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // User Avatar
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text(user.name.prefix(1).uppercased())
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                        .padding(.top, 20)

                    // User Info
                    VStack(spacing: 8) {
                        Text(user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        RoleBadge(role: user.role)
                    }

                    // Details
                    VStack(spacing: 16) {
                        DetailRow(icon: "briefcase", label: "Department", value: user.department ?? "N/A")
                        DetailRow(icon: "phone", label: "Phone", value: user.phoneNumber ?? "N/A")
                        DetailRow(icon: "calendar", label: "Created", value: user.createdAt.formatted(date: .abbreviated, time: .omitted))
                        DetailRow(
                            icon: "clock",
                            label: "Last Login",
                            value: user.lastLoginAt?.formatted(date: .abbreviated, time: .shortened) ?? "Never"
                        )
                        DetailRow(icon: "checkmark.circle", label: "Status", value: user.isActive ? "Active" : "Inactive")
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Permissions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Permissions")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(user.role.permissions, id: \.self) { permission in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(permission.rawValue)
                                        .font(.subheadline)
                                    Spacer()
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }

                    // Actions
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.toggleUserStatus(user)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: user.isActive ? "pause.circle" : "play.circle")
                                Text(user.isActive ? "Deactivate User" : "Activate User")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(user.isActive ? Color.orange : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            viewModel.deleteUser(user)
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Delete User")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color(.systemGray6))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        UserManagementView()
    }
}
