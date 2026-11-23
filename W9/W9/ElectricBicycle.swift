import Foundation

class ElectricBicycle: Vehicle {
    private(set) var batteryRangeKm: Int
    private(set) var batteryMaintenanceFeePerDay: Double

    init(id: String, brand: String, model: String, dailyRate: Double, batteryRangeKm: Int, batteryFeePerDay: Double = 3.50) {
        self.batteryRangeKm = batteryRangeKm
        self.batteryMaintenanceFeePerDay = batteryFeePerDay
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate)
    }

    override func calculateRentalCost(days: Int) -> Double {
        let baseCost = super.calculateRentalCost(days: days)
        let batteryCost = batteryMaintenanceFeePerDay * Double(days)
        return baseCost + batteryCost
    }

    override func getDetails() -> String {
        return "\(super.getDetails()) | Type: E-Bike (Range: \(batteryRangeKm)km, Battery Fee: $\(String(format: "%.2f", batteryMaintenanceFeePerDay))/day)"
    }
}
