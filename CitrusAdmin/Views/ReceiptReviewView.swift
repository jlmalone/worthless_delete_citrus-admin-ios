//
//  ReceiptReviewView.swift
//  CitrusAdmin
//
//  Receipt review and management view
//

import SwiftUI

struct ReceiptReviewView: View {
    @StateObject private var viewModel = ReceiptViewModel()
    @EnvironmentObject var appState: AppState
    @State private var selectedReceipt: Receipt?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and Filter
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search receipts...", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Status Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            FilterChip(
                                title: "All",
                                isSelected: viewModel.selectedStatus == nil,
                                action: { viewModel.selectedStatus = nil }
                            )
                            ForEach(ReceiptStatus.allCases, id: \.self) { status in
                                FilterChip(
                                    title: status.rawValue,
                                    isSelected: viewModel.selectedStatus == status,
                                    action: { viewModel.selectedStatus = status }
                                )
                            }
                        }
                    }

                    // Category Filters
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(ReceiptCategory.allCases, id: \.self) { category in
                                CategoryFilterChip(
                                    category: category,
                                    isSelected: viewModel.selectedCategory == category,
                                    action: {
                                        viewModel.selectedCategory = viewModel.selectedCategory == category ? nil : category
                                    }
                                )
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Stats Bar
                HStack(spacing: 20) {
                    StatBadge(
                        icon: "clock.fill",
                        count: viewModel.pendingCount,
                        label: "Pending",
                        color: .orange
                    )
                    StatBadge(
                        icon: "flag.fill",
                        count: viewModel.flaggedCount,
                        label: "Flagged",
                        color: .yellow
                    )
                }
                .padding()
                .background(Color(.systemGray6))

                Divider()

                // Receipt List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredReceipts.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No receipts found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredReceipts) { receipt in
                            ReceiptRow(receipt: receipt)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedReceipt = receipt
                                }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Receipts (\(viewModel.filteredReceipts.count))")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.loadMockData() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .sheet(item: $selectedReceipt) { receipt in
                ReceiptDetailView(receipt: receipt, viewModel: viewModel, currentUser: appState.currentUser)
            }
        }
    }
}

struct ReceiptRow: View {
    let receipt: Receipt

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Category Icon
                Image(systemName: receipt.category.icon)
                    .foregroundColor(.orange)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.merchantName)
                        .font(.headline)
                    Text(receipt.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(receipt.formattedAmount)
                        .font(.headline)
                    StatusBadge(status: receipt.status)
                }
            }

            if receipt.notes != nil {
                Text(receipt.notes!)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                Label(receipt.category.rawValue, systemImage: "tag")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if receipt.reviewedBy != nil {
                    Spacer()
                    Label("Reviewed", systemImage: "checkmark.seal")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: ReceiptStatus

    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundColor(statusColor)
            .cornerRadius(6)
    }

    var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        case .flagged: return .yellow
        }
    }
}

struct CategoryFilterChip: View {
    let category: ReceiptCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.orange : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
    }
}

struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            VStack(alignment: .leading, spacing: 2) {
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct ReceiptDetailView: View {
    let receipt: Receipt
    @ObservedObject var viewModel: ReceiptViewModel
    let currentUser: User?
    @Environment(\.dismiss) var dismiss
    @State private var showingApprovalAlert = false
    @State private var showingRejectionAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Receipt Header
                    VStack(spacing: 12) {
                        Image(systemName: receipt.category.icon)
                            .font(.system(size: 60))
                            .foregroundColor(.orange)

                        Text(receipt.merchantName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(receipt.formattedAmount)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        StatusBadge(status: receipt.status)
                    }
                    .padding()

                    // Receipt Details
                    VStack(spacing: 16) {
                        DetailRow(icon: "tag", label: "Category", value: receipt.category.rawValue)
                        DetailRow(icon: "calendar", label: "Date", value: receipt.date.formatted(date: .long, time: .omitted))
                        DetailRow(icon: "creditcard", label: "Receipt ID", value: receipt.id)
                        if let tax = receipt.taxAmount {
                            DetailRow(icon: "percent", label: "Tax", value: String(format: "$%.2f", tax))
                        }
                        if let tip = receipt.tipAmount {
                            DetailRow(icon: "banknote", label: "Tip", value: String(format: "$%.2f", tip))
                        }
                        if let reviewedBy = receipt.reviewedBy, let reviewedAt = receipt.reviewedAt {
                            DetailRow(icon: "person.circle", label: "Reviewed By", value: reviewedBy)
                            DetailRow(icon: "clock", label: "Reviewed At", value: reviewedAt.formatted(date: .abbreviated, time: .shortened))
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 2)
                    .padding(.horizontal)

                    // Notes
                    if let notes = receipt.notes {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Notes")
                                .font(.headline)
                            Text(notes)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }

                    // Items
                    if !receipt.items.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Items")
                                .font(.headline)
                                .padding(.horizontal)

                            VStack(spacing: 8) {
                                ForEach(receipt.items) { item in
                                    HStack {
                                        Text("\(item.quantity)x")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .frame(width: 30)
                                        Text(item.name)
                                            .font(.subheadline)
                                        Spacer()
                                        Text(String(format: "$%.2f", item.totalPrice))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                    }

                    // Actions (only for pending/flagged receipts)
                    if receipt.status == .pending || receipt.status == .flagged {
                        VStack(spacing: 12) {
                            Button(action: {
                                showingApprovalAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "checkmark.circle")
                                    Text("Approve Receipt")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            Button(action: {
                                showingRejectionAlert = true
                            }) {
                                HStack {
                                    Image(systemName: "xmark.circle")
                                    Text("Reject Receipt")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }

                            if receipt.status != .flagged {
                                Button(action: {
                                    viewModel.flagReceipt(receipt)
                                    dismiss()
                                }) {
                                    HStack {
                                        Image(systemName: "flag")
                                        Text("Flag for Review")
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
            .alert("Approve Receipt", isPresented: $showingApprovalAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Approve") {
                    if let userId = currentUser?.id {
                        viewModel.approveReceipt(receipt, reviewedBy: userId)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to approve this receipt?")
            }
            .alert("Reject Receipt", isPresented: $showingRejectionAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reject", role: .destructive) {
                    if let userId = currentUser?.id {
                        viewModel.rejectReceipt(receipt, reviewedBy: userId)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to reject this receipt?")
            }
        }
    }
}

struct ReceiptReviewView_Previews: PreviewProvider {
    static var previews: some View {
        ReceiptReviewView()
            .environmentObject(AppState())
    }
}
