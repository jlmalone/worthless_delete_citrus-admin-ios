//
//  DashboardView.swift
//  CitrusAdmin
//
//  Analytics dashboard view showing key metrics
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Citrus Admin")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            Text("Dashboard Overview")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: { viewModel.refreshAnalytics() }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title3)
                        }
                    }
                    .padding()

                    // Key Metrics
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        MetricCard(
                            title: "Total Receipts",
                            value: "\(viewModel.summary.totalReceipts)",
                            icon: "doc.text.fill",
                            color: .blue
                        )
                        MetricCard(
                            title: "Total Amount",
                            value: viewModel.summary.formattedTotalAmount,
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        MetricCard(
                            title: "Pending Review",
                            value: "\(viewModel.summary.pendingReceipts)",
                            icon: "clock.fill",
                            color: .orange
                        )
                        MetricCard(
                            title: "Active Users",
                            value: "\(viewModel.summary.activeUsers)",
                            icon: "person.3.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)

                    // Status Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Receipt Status")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            StatusRow(
                                label: "Approved",
                                count: viewModel.summary.approvedReceipts,
                                percentage: viewModel.approvalRate,
                                color: .green
                            )
                            StatusRow(
                                label: "Pending",
                                count: viewModel.summary.pendingReceipts,
                                percentage: viewModel.pendingRate,
                                color: .orange
                            )
                            StatusRow(
                                label: "Rejected",
                                count: viewModel.summary.rejectedReceipts,
                                percentage: viewModel.rejectionRate,
                                color: .red
                            )
                            StatusRow(
                                label: "Flagged",
                                count: viewModel.summary.flaggedReceipts,
                                percentage: Double(viewModel.summary.flaggedReceipts) / Double(viewModel.summary.totalReceipts) * 100,
                                color: .yellow
                            )
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }

                    // Top Categories
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Top Categories")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(viewModel.summary.topCategories.prefix(5)) { category in
                                CategoryRow(category: category)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }

                    // Recent Activity
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Activity")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 8) {
                            ForEach(viewModel.summary.recentActivity.prefix(6)) { activity in
                                ActivityRow(activity: activity)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct StatusRow: View {
    let label: String
    let count: Int
    let percentage: Double
    let color: Color

    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(count)")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(String(format: "%.1f%%", percentage))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CategoryRow: View {
    let category: CategoryAnalytics

    var body: some View {
        HStack {
            Image(systemName: category.category.icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            Text(category.category.rawValue)
                .font(.subheadline)
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(category.count) receipts")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(String(format: "$%.2f", category.totalAmount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
    }
}

struct ActivityRow: View {
    let activity: ActivityItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: activity.icon)
                .foregroundColor(.orange)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.description)
                    .font(.subheadline)
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
