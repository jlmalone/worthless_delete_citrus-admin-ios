//
//  ReceiptViewModel.swift
//  CitrusAdmin
//
//  ViewModel for receipt management using Combine
//

import Foundation
import Combine

class ReceiptViewModel: ObservableObject {
    @Published var receipts: [Receipt] = []
    @Published var filteredReceipts: [Receipt] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: ReceiptStatus?
    @Published var selectedCategory: ReceiptCategory?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    init() {
        loadMockData()
        setupSearchAndFilter()
    }

    private func setupSearchAndFilter() {
        Publishers.CombineLatest3($searchText, $selectedStatus, $selectedCategory)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] searchText, status, category in
                self?.filterReceipts(searchText: searchText, status: status, category: category)
            }
            .store(in: &cancellables)
    }

    private func filterReceipts(searchText: String, status: ReceiptStatus?, category: ReceiptCategory?) {
        var filtered = receipts

        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.merchantName.localizedCaseInsensitiveContains(searchText) ||
                $0.id.localizedCaseInsensitiveContains(searchText)
            }
        }

        if let status = status {
            filtered = filtered.filter { $0.status == status }
        }

        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }

        filteredReceipts = filtered.sorted { $0.date > $1.date }
    }

    func loadMockData() {
        isLoading = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            self.receipts = [
                Receipt(id: "R001", userId: "1", merchantName: "Starbucks", amount: 15.50, date: Date().addingTimeInterval(-86400), category: .meals, status: .pending),
                Receipt(id: "R002", userId: "2", merchantName: "Delta Airlines", amount: 450.00, date: Date().addingTimeInterval(-172800), category: .travel, status: .approved),
                Receipt(id: "R003", userId: "3", merchantName: "Office Depot", amount: 89.99, date: Date().addingTimeInterval(-259200), category: .office, status: .pending),
                Receipt(id: "R004", userId: "1", merchantName: "Uber", amount: 32.50, date: Date().addingTimeInterval(-345600), category: .travel, status: .approved),
                Receipt(id: "R005", userId: "4", merchantName: "Best Buy", amount: 1200.00, date: Date().addingTimeInterval(-432000), category: .equipment, status: .flagged),
                Receipt(id: "R006", userId: "2", merchantName: "Restaurant XYZ", amount: 125.00, date: Date().addingTimeInterval(-518400), category: .entertainment, status: .approved),
                Receipt(id: "R007", userId: "5", merchantName: "Amazon", amount: 67.89, date: Date().addingTimeInterval(-604800), category: .office, status: .rejected),
                Receipt(id: "R008", userId: "3", merchantName: "Hilton Hotel", amount: 350.00, date: Date().addingTimeInterval(-691200), category: .travel, status: .pending),
                Receipt(id: "R009", userId: "6", merchantName: "Chipotle", amount: 18.75, date: Date().addingTimeInterval(-7200), category: .meals, status: .pending),
                Receipt(id: "R010", userId: "7", merchantName: "Apple Store", amount: 999.00, date: Date().addingTimeInterval(-14400), category: .equipment, status: .flagged)
            ]
            self.filteredReceipts = self.receipts.sorted { $0.date > $1.date }
            self.isLoading = false
        }
    }

    func approveReceipt(_ receipt: Receipt, reviewedBy: String) {
        var updated = receipt
        updated.status = .approved
        updated.reviewedBy = reviewedBy
        updated.reviewedAt = Date()
        updateReceipt(updated)
    }

    func rejectReceipt(_ receipt: Receipt, reviewedBy: String) {
        var updated = receipt
        updated.status = .rejected
        updated.reviewedBy = reviewedBy
        updated.reviewedAt = Date()
        updateReceipt(updated)
    }

    func flagReceipt(_ receipt: Receipt) {
        var updated = receipt
        updated.status = .flagged
        updateReceipt(updated)
    }

    private func updateReceipt(_ receipt: Receipt) {
        if let index = receipts.firstIndex(where: { $0.id == receipt.id }) {
            receipts[index] = receipt
            filterReceipts(searchText: searchText, status: selectedStatus, category: selectedCategory)
        }
    }

    var pendingCount: Int {
        receipts.filter { $0.status == .pending }.count
    }

    var flaggedCount: Int {
        receipts.filter { $0.status == .flagged }.count
    }
}
