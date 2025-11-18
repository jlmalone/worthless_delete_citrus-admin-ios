//
//  ContentView.swift
//  CitrusAdmin
//
//  Main navigation view for the admin app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "chart.bar.fill")
                }
                .tag(0)

            ReceiptReviewView()
                .tabItem {
                    Label("Receipts", systemImage: "doc.text.fill")
                }
                .tag(1)

            UserManagementView()
                .tabItem {
                    Label("Users", systemImage: "person.3.fill")
                }
                .tag(2)

            AlertsView()
                .tabItem {
                    Label("Alerts", systemImage: "bell.fill")
                }
                .tag(3)
        }
        .accentColor(.orange)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
