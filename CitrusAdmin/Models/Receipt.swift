//
//  Receipt.swift
//  CitrusAdmin
//
//  Receipt model for receipt review and management
//

import Foundation

struct Receipt: Identifiable, Codable {
    let id: String
    var userId: String
    var merchantName: String
    var amount: Double
    var currency: String
    var date: Date
    var category: ReceiptCategory
    var status: ReceiptStatus
    var imageUrl: String?
    var notes: String?
    var reviewedBy: String?
    var reviewedAt: Date?
    var items: [ReceiptItem]
    var taxAmount: Double?
    var tipAmount: Double?

    init(
        id: String,
        userId: String,
        merchantName: String,
        amount: Double,
        currency: String = "USD",
        date: Date,
        category: ReceiptCategory,
        status: ReceiptStatus,
        imageUrl: String? = nil,
        notes: String? = nil,
        reviewedBy: String? = nil,
        reviewedAt: Date? = nil,
        items: [ReceiptItem] = [],
        taxAmount: Double? = nil,
        tipAmount: Double? = nil
    ) {
        self.id = id
        self.userId = userId
        self.merchantName = merchantName
        self.amount = amount
        self.currency = currency
        self.date = date
        self.category = category
        self.status = status
        self.imageUrl = imageUrl
        self.notes = notes
        self.reviewedBy = reviewedBy
        self.reviewedAt = reviewedAt
        self.items = items
        self.taxAmount = taxAmount
        self.tipAmount = tipAmount
    }

    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}

struct ReceiptItem: Identifiable, Codable {
    let id: String
    var name: String
    var quantity: Int
    var unitPrice: Double
    var totalPrice: Double

    init(id: String = UUID().uuidString, name: String, quantity: Int, unitPrice: Double, totalPrice: Double) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
    }
}

enum ReceiptCategory: String, Codable, CaseIterable {
    case meals = "Meals"
    case travel = "Travel"
    case office = "Office"
    case entertainment = "Entertainment"
    case equipment = "Equipment"
    case other = "Other"

    var icon: String {
        switch self {
        case .meals: return "fork.knife"
        case .travel: return "airplane"
        case .office: return "building.2"
        case .entertainment: return "tv"
        case .equipment: return "laptopcomputer"
        case .other: return "tag"
        }
    }
}

enum ReceiptStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case approved = "Approved"
    case rejected = "Rejected"
    case flagged = "Flagged"

    var color: String {
        switch self {
        case .pending: return "orange"
        case .approved: return "green"
        case .rejected: return "red"
        case .flagged: return "yellow"
        }
    }
}
