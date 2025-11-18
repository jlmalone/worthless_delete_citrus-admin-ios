//
//  AnalyticsViewModel.swift
//  CitrusAdmin
//
//  ViewModel for analytics and dashboard metrics using Combine
//

import Foundation
import Combine

class AnalyticsViewModel: ObservableObject {
    @Published var summary: AnalyticsSummary
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedTimeRange: TimeRange = .thisMonth

    private var cancellables = Set<AnyCancellable>()

    init() {
        self.summary = AnalyticsSummary()
        loadAnalytics()
        setupRefreshTimer()
    }

    private func setupRefreshTimer() {
        Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshAnalytics()
            }
            .store(in: &cancellables)
    }

    func loadAnalytics() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.summary = AnalyticsSummary(
                totalReceipts: 847,
                totalAmount: 125_430.50,
                pendingReceipts: 23,
                approvedReceipts: 782,
                rejectedReceipts: 34,
                flaggedReceipts: 8,
                activeUsers: 142,
                averageProcessingTime: 3600 * 4.5, // 4.5 hours
                topCategories: [
                    CategoryAnalytics(category: .travel, count: 315, totalAmount: 68_450.00, percentage: 54.6),
                    CategoryAnalytics(category: .meals, count: 245, totalAmount: 28_320.50, percentage: 22.6),
                    CategoryAnalytics(category: .office, count: 158, totalAmount: 15_780.00, percentage: 12.6),
                    CategoryAnalytics(category: .equipment, count: 89, totalAmount: 11_230.00, percentage: 8.9),
                    CategoryAnalytics(category: .entertainment, count: 40, totalAmount: 1_650.00, percentage: 1.3)
                ],
                recentActivity: [
                    ActivityItem(type: .receiptSubmitted, description: "New receipt from John Doe - $45.50", timestamp: Date().addingTimeInterval(-300)),
                    ActivityItem(type: .receiptApproved, description: "Receipt R234 approved by Admin", timestamp: Date().addingTimeInterval(-900)),
                    ActivityItem(type: .alertTriggered, description: "High amount alert for $2,500 receipt", timestamp: Date().addingTimeInterval(-1800)),
                    ActivityItem(type: .receiptSubmitted, description: "New receipt from Jane Smith - $125.00", timestamp: Date().addingTimeInterval(-3600)),
                    ActivityItem(type: .userCreated, description: "New user: Bob Johnson", timestamp: Date().addingTimeInterval(-7200)),
                    ActivityItem(type: .receiptRejected, description: "Receipt R189 rejected - duplicate", timestamp: Date().addingTimeInterval(-10800))
                ]
            )
            self?.isLoading = false
        }
    }

    func refreshAnalytics() {
        loadAnalytics()
    }

    var approvalRate: Double {
        let total = summary.totalReceipts
        guard total > 0 else { return 0 }
        return Double(summary.approvedReceipts) / Double(total) * 100
    }

    var rejectionRate: Double {
        let total = summary.totalReceipts
        guard total > 0 else { return 0 }
        return Double(summary.rejectedReceipts) / Double(total) * 100
    }

    var pendingRate: Double {
        let total = summary.totalReceipts
        guard total > 0 else { return 0 }
        return Double(summary.pendingReceipts) / Double(total) * 100
    }

    var chartData: [ChartData] {
        [
            ChartData(label: "Approved", value: Double(summary.approvedReceipts), color: "green"),
            ChartData(label: "Pending", value: Double(summary.pendingReceipts), color: "orange"),
            ChartData(label: "Rejected", value: Double(summary.rejectedReceipts), color: "red"),
            ChartData(label: "Flagged", value: Double(summary.flaggedReceipts), color: "yellow")
        ]
    }
}

enum TimeRange: String, CaseIterable {
    case today = "Today"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case thisYear = "This Year"
}
