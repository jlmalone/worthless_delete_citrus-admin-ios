//
//  AlertViewModel.swift
//  CitrusAdmin
//
//  ViewModel for alert management using Combine
//

import Foundation
import Combine

class AlertViewModel: ObservableObject {
    @Published var alerts: [Alert] = []
    @Published var filteredAlerts: [Alert] = []
    @Published var selectedSeverity: AlertSeverity?
    @Published var showResolved: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockData()
        setupFilter()
    }

    private func setupFilter() {
        Publishers.CombineLatest($selectedSeverity, $showResolved)
            .sink { [weak self] severity, showResolved in
                self?.filterAlerts(severity: severity, showResolved: showResolved)
            }
            .store(in: &cancellables)
    }

    private func filterAlerts(severity: AlertSeverity?, showResolved: Bool) {
        var filtered = alerts

        if let severity = severity {
            filtered = filtered.filter { $0.severity == severity }
        }

        if !showResolved {
            filtered = filtered.filter { !$0.isResolved }
        }

        filteredAlerts = filtered.sorted { $0.timestamp > $1.timestamp }
    }

    func loadMockData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            self.alerts = [
                Alert(
                    title: "High Amount Receipt",
                    message: "Receipt R005 for $2,500.00 requires review",
                    severity: .warning,
                    type: .highAmount,
                    timestamp: Date().addingTimeInterval(-1800),
                    relatedReceiptId: "R005",
                    actionRequired: true
                ),
                Alert(
                    title: "Duplicate Receipt Detected",
                    message: "Potential duplicate: R007 matches R006",
                    severity: .warning,
                    type: .duplicateReceipt,
                    timestamp: Date().addingTimeInterval(-3600),
                    relatedReceiptId: "R007",
                    actionRequired: true
                ),
                Alert(
                    title: "Suspicious Activity",
                    message: "Multiple receipts from same merchant in short time",
                    severity: .error,
                    type: .suspiciousActivity,
                    timestamp: Date().addingTimeInterval(-7200),
                    relatedUserId: "3",
                    actionRequired: true
                ),
                Alert(
                    title: "Pending Review Queue Full",
                    message: "23 receipts pending review, action needed",
                    severity: .warning,
                    type: .pendingReview,
                    timestamp: Date().addingTimeInterval(-10800),
                    actionRequired: true
                ),
                Alert(
                    title: "User Account Inactive",
                    message: "User charlie.brown@citrus.com has been inactive for 30 days",
                    severity: .info,
                    type: .userInactive,
                    timestamp: Date().addingTimeInterval(-14400),
                    relatedUserId: "5",
                    actionRequired: false
                ),
                Alert(
                    title: "System Performance",
                    message: "Receipt processing time increased by 25%",
                    severity: .info,
                    type: .systemError,
                    timestamp: Date().addingTimeInterval(-18000),
                    actionRequired: false,
                    isResolved: true,
                    resolvedBy: "admin-1",
                    resolvedAt: Date().addingTimeInterval(-3600)
                ),
                Alert(
                    title: "Compliance Issue",
                    message: "Missing tax information on 5 receipts",
                    severity: .error,
                    type: .complianceIssue,
                    timestamp: Date().addingTimeInterval(-21600),
                    actionRequired: true
                ),
                Alert(
                    title: "High Volume Alert",
                    message: "Receipt submission rate 3x normal",
                    severity: .critical,
                    type: .suspiciousActivity,
                    timestamp: Date().addingTimeInterval(-25200),
                    actionRequired: true
                )
            ]
            self.filteredAlerts = self.alerts.filter { !$0.isResolved }.sorted { $0.timestamp > $1.timestamp }
            self.isLoading = false
        }
    }

    func markAsRead(_ alert: Alert) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isRead = true
            filterAlerts(severity: selectedSeverity, showResolved: showResolved)
        }
    }

    func resolveAlert(_ alert: Alert, resolvedBy: String) {
        if let index = alerts.firstIndex(where: { $0.id == alert.id }) {
            alerts[index].isResolved = true
            alerts[index].resolvedBy = resolvedBy
            alerts[index].resolvedAt = Date()
            filterAlerts(severity: selectedSeverity, showResolved: showResolved)
        }
    }

    var unreadCount: Int {
        alerts.filter { !$0.isRead && !$0.isResolved }.count
    }

    var criticalCount: Int {
        alerts.filter { $0.severity == .critical && !$0.isResolved }.count
    }

    var actionRequiredCount: Int {
        alerts.filter { $0.actionRequired && !$0.isResolved }.count
    }
}
