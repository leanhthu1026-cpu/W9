import Foundation

enum EngineCategory: String {
    case standard = "Standard (< 250cc)"
    case sport = "Sport (250cc - 600cc)"
    case heavy = "Heavy (> 600cc)"

    var dailySurcharge: Double {
        switch self {
        case .standard: return 5.0
        case .sport: return 15.0
        case .heavy: return 30.0
        }
    }
}

class Motorcycle: Vehicle {
    private(set) var engineCC: Int
    private(set) var category: EngineCategory

    init(id: String, brand: String, model: String, dailyRate: Double, engineCC: Int) {
        self.engineCC = engineCC
        if engineCC < 250 {
            self.category = .standard
        } else if engineCC <= 600 {
            self.category = .sport
        } else {
            self.category = .heavy
        }
        super.init(id: id, brand: brand, model: model, dailyRate: dailyRate)
    }

    override func calculateRentalCost(days: Int) -> Double {
        let baseCost = super.calculateRentalCost(days: days)
        let categoryCost = category.dailySurcharge * Double(days)
        return baseCost + categoryCost
    }

    override func getDetails() -> String {
        return "\(super.getDetails()) | Type: Motorcycle (\(engineCC)cc - \(category.rawValue))"
    }
}
