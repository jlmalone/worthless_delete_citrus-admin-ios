//
//  AlertsView.swift
//  CitrusAdmin
//
//  Alerts and notifications view
//

import SwiftUI

struct AlertsView: View {
    @StateObject private var viewModel = AlertViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedAlert: Alert?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Alert Stats
                HStack(spacing: 16) {
                    AlertStatCard(
                        icon: "exclamationmark.octagon.fill",
                        count: viewModel.criticalCount,
                        label: "Critical",
                        color: .red
                    )
                    AlertStatCard(
                        icon: "exclamationmark.triangle.fill",
                        count: viewModel.actionRequiredCount,
                        label: "Action Required",
                        color: .orange
                    )
                    AlertStatCard(
                        icon: "envelope.badge.fill",
                        count: viewModel.unreadCount,
                        label: "Unread",
                        color: .blue
                    )
                }
                .padding()
                .background(Color(.systemBackground))

                // Filters
                VStack(spacing: 12) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedSeverity == nil,
                                action: { viewModel.selectedSeverity = nil }
                            )
                            ForEach(AlertSeverity.allCases, id: \.self) { severity in
                                SeverityFilterChip(
                                    severity: severity,
                                    isSelected: viewModel.selectedSeverity == severity,
                                    action: { viewModel.selectedSeverity = severity }
                                )
                            }
                        }
                    }

                    Toggle("Show Resolved", isOn: $viewModel.showResolved)
                        .padding(.horizontal)
                }
                .padding(.bottom)
                .background(Color(.systemBackground))

                Divider()

                // Alert List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredAlerts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        Text("No alerts")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Everything looks good!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredAlerts) { alert in
                            AlertRow(alert: alert)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.markAsRead(alert)
                                    selectedAlert = alert
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Alerts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.loadMockData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert, viewModel: viewModel, currentUser: appState.currentUser)
            }
        }
    }
}

struct AlertRow: View {
    let alert: Alert

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Severity Icon
            Image(systemName: alert.severity.icon)
                .font(.title3)
                .foregroundColor(severityColor)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(alert.title)
                        .font(.headline)
                        .fontWeight(alert.isRead ? .regular : .bold)

                    if !alert.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }

                Text(alert.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                HStack {
                    Text(alert.timeAgo)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if alert.actionRequired {
                        Spacer()
                        Label("Action Required", systemImage: "exclamationmark.circle")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }

                    if alert.isResolved {
                        Spacer()
                        Label("Resolved", systemImage: "checkmark.circle")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }

            Spacer()

            SeverityBadge(severity: alert.severity)
        }
        .padding(.vertical, 8)
    }

    var severityColor: Color {
        switch alert.severity {
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }
}

struct SeverityBadge: View {
    let severity: AlertSeverity

    var body: some View {
        Text(severity.rawValue)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(severityColor.opacity(0.2))
            .foregroundColor(severityColor)
            .cornerRadius(4)
    }

    var severityColor: Color {
        switch severity {
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }
}

struct SeverityFilterChip: View {
    let severity: AlertSeverity
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: severity.icon)
                Text(severity.rawValue)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? severityColor : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }

    var severityColor: Color {
        switch severity {
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }
}

struct AlertStatCard: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text("\(count)")
                .font(.title3)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AlertDetailView: View {
    let alert: Alert
    @ObservedObject var viewModel: AlertViewModel
    let currentUser: User?
    @Environment(\.dismiss) var dismiss
    @State private var showingResolveAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Alert Header
                    VStack(spacing: 12) {
                        Image(systemName: alert.severity.icon)
                            .font(.system(size: 60))
                            .foregroundColor(severityColor)

                        Text(alert.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)

                        SeverityBadge(severity: alert.severity)

                        Text(alert.timestamp.formatted(date: .long, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()

                    // Alert Message
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Message")
                            .font(.headline)
                        Text(alert.message)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Alert Details
                    VStack(spacing: 16) {
                        DetailRow(icon: "tag", label: "Type", value: alert.type.rawValue)
                        DetailRow(icon: "flag", label: "Action Required", value: alert.actionRequired ? "Yes" : "No")

                        if let receiptId = alert.relatedReceiptId {
                            DetailRow(icon: "doc.text", label: "Related Receipt", value: receiptId)
                        }

                        if let userId = alert.relatedUserId {
                            DetailRow(icon: "person", label: "Related User", value: userId)
                        }

                        if alert.isResolved {
                            Divider()
                            if let resolvedBy = alert.resolvedBy {
                                DetailRow(icon: "person.circle", label: "Resolved By", value: resolvedBy)
                            }
                            if let resolvedAt = alert.resolvedAt {
                                DetailRow(icon: "clock", label: "Resolved At", value: resolvedAt.formatted(date: .abbreviated, time: .shortened))
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Actions
                    if !alert.isResolved && alert.actionRequired {
                        VStack(spacing: 12) {
                            Button(action: {
                                showingResolveAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("Mark as Resolved")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            if let receiptId = alert.relatedReceiptId {
                                NavigationLink(destination: Text("Receipt \(receiptId)")) {
                                    HStack {
                                        Image(systemName: "doc.text")
                                        Text("View Related Receipt")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
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
            .alert("Resolve Alert", isPresented: $showingResolveAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Resolve") {
                    if let userId = currentUser?.id {
                        viewModel.resolveAlert(alert, resolvedBy: userId)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to mark this alert as resolved?")
            }
        }
    }

    var severityColor: Color {
        switch alert.severity {
        case .info: return .blue
        case .warning: return .yellow
        case .error: return .orange
        case .critical: return .red
        }
    }
}

struct AlertsView_Previews: PreviewProvider {
    static var previews: some View {
        AlertsView()
            .environmentObject(AppState())
    }
}
