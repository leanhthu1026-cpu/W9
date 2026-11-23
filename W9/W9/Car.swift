import Foundation

class Car: Vehicle {
    private(set) var seatingCapacity: Int
    private(set) var insuranceAndCleaningFee: Double

    init(id: String, brand: String, model: String, dailyRate: Double, seatingCapacity: Int, insuranceAndCleaningFee: Double = 25.0) {
        self.seatingCapacity = seatingCapacity
        self.insuranceAndCleaningFee = insuranceAndCleaningFee
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate)
    }

    func updateCarDetails(seatingCapacity: Int? = nil, serviceFee: Double? = nil) {
        if let seats = seatingCapacity, seats > 0 { self.seatingCapacity = seats }
        if let fee = serviceFee, fee >= 0 { self.insuranceAndCleaningFee = fee }
    }

    override func calculateRentalCost(days: Int) -> Double {
        let baseCost = super.calculateRentalCost(days: days)
        return baseCost + insuranceAndCleaningFee
    }

    override func getDetails() -> String {
        return "\(super.getDetails()) | Type: Car (\(seatingCapacity) Seats, Service Fee: $\(String(format: "%.2f", insuranceAndCleaningFee)))"
    }
}
