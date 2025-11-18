//
//  DataService.swift
//  CitrusAdmin
//
//  Service layer for data management and API integration
//

import Foundation
import Combine

protocol DataServiceProtocol {
    func fetchUsers() -> AnyPublisher<[User], Error>
    func fetchReceipts() -> AnyPublisher<[Receipt], Error>
    func fetchAnalytics() -> AnyPublisher<AnalyticsSummary, Error>
    func fetchAlerts() -> AnyPublisher<[Alert], Error>
}

class DataService: DataServiceProtocol {
    static let shared = DataService()

    private init() {}

    // MARK: - API Integration Points
    // In a production environment, these would connect to actual API endpoints

    func fetchUsers() -> AnyPublisher<[User], Error> {
        // Mock implementation - replace with actual API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let users = self.generateMockUsers()
                promise(.success(users))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchReceipts() -> AnyPublisher<[Receipt], Error> {
        // Mock implementation - replace with actual API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let receipts = self.generateMockReceipts()
                promise(.success(receipts))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchAnalytics() -> AnyPublisher<AnalyticsSummary, Error> {
        // Mock implementation - replace with actual API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let analytics = self.generateMockAnalytics()
                promise(.success(analytics))
            }
        }
        .eraseToAnyPublisher()
    }

    func fetchAlerts() -> AnyPublisher<[Alert], Error> {
        // Mock implementation - replace with actual API call
        return Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let alerts = self.generateMockAlerts()
                promise(.success(alerts))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Mock Data Generators

    private func generateMockUsers() -> [User] {
        return [
            User(id: "1", email: "admin@citrus.com", name: "Admin User", role: .admin, isActive: true),
            User(id: "2", email: "manager@citrus.com", name: "Manager User", role: .manager, isActive: true)
        ]
    }

    private func generateMockReceipts() -> [Receipt] {
        return [
            Receipt(id: "R001", userId: "1", merchantName: "Test Merchant", amount: 100.00, date: Date(), category: .meals, status: .pending)
        ]
    }

    private func generateMockAnalytics() -> AnalyticsSummary {
        return AnalyticsSummary(
            totalReceipts: 100,
            totalAmount: 10000.00,
            pendingReceipts: 10,
            approvedReceipts: 80,
            rejectedReceipts: 10,
            flaggedReceipts: 5,
            activeUsers: 50
        )
    }

    private func generateMockAlerts() -> [Alert] {
        return [
            Alert(title: "Test Alert", message: "This is a test alert", severity: .info, type: .pendingReview)
        ]
    }
}

// MARK: - API Client (Placeholder for future implementation)
class APIClient {
    static let shared = APIClient()
    private let baseURL = "https://api.citrus.com/v1"

    private init() {}

    func request<T: Decodable>(_ endpoint: String) -> AnyPublisher<T, Error> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
