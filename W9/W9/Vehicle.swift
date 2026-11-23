import Foundation

class Vehicle {
    let id: String
    private(set) var brand: String
    private(set) var model: String
    private(set) var dailyRate: Double
    private(set) var isAvailable: Bool

    init(id: String, brand: String, model: String, dailyRate: Double) {
        self.id = id
        self.brand = brand
        self.model = model
        self.dailyRate = dailyRate
        self.isAvailable = true
    }

    // Cập nhật thông tin đóng gói (Encapsulation)
    func updateInfo(brand: String? = nil, model: String? = nil, dailyRate: Double? = nil) {
        if let brand = brand { self.brand = brand }
        if let model = model { self.model = model }
        if let dailyRate = dailyRate, dailyRate > 0 { self.dailyRate = dailyRate }
    }

    func setAvailability(_ available: Bool) {
        self.isAvailable = available
    }

    // Phương thức đa hình (Polymorphism)
    func calculateRentalCost(days: Int) -> Double {
        return dailyRate * Double(days)
    }

    func getDetails() -> String {
        let status = isAvailable ? "Available" : "Rented"
        return "[\(id)] \(brand) \(model) | Rate: $\(String(format: "%.2f", dailyRate))/day | Status: \(status)"
    }
}
