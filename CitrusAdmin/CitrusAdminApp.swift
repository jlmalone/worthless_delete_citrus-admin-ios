//
//  CitrusAdminApp.swift
//  CitrusAdmin
//
//  Citrus Enterprise Receipt Intelligence Platform - iOS Admin
//

import SwiftUI

@main
struct CitrusAdminApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}

class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    init() {
        // Initialize with demo authentication
        self.isAuthenticated = true
        self.currentUser = User(
            id: "admin-1",
            email: "admin@citrus.com",
            name: "Admin User",
            role: .admin,
            isActive: true
        )
    }
}
