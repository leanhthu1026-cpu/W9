import Foundation

enum RentalStatus: String {
    case active = "Active"
    case completed = "Returned / Completed"
}

class Rental {
    let rentalId: String
    let customer: Customer
    let vehicle: Vehicle
    let startDate: Date
    let durationDays: Int
    let endDate: Date
    let totalCost: Double
    private(set) var status: RentalStatus

    init(rentalId: String, customer: Customer, vehicle: Vehicle, startDate: Date = Date(), durationDays: Int) {
        self.rentalId = rentalId
        self.customer = customer
        self.vehicle = vehicle
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.durationDays = durationDays
        self.endDate = Calendar.current.date(byAdding: .day, value: durationDays, to: self.startDate) ?? self.startDate
        self.totalCost = vehicle.calculateRentalCost(days: durationDays)
        self.status = .active
    }

    func completeRental() {
        self.status = .completed
    }

    /// Kiểm tra xe có đang bị chiếm lịch vào một ngày cụ thể hay không
    func covers(date: Date) -> Bool {
        let targetDay = Calendar.current.startOfDay(for: date)
        return status == .active && targetDay >= startDate && targetDay < endDate
    }

    func displaySummary() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return """
        ------------------------------------------------------------
        RENTAL RECEIPT [\(rentalId)] - Status: \(status.rawValue)
        Customer : \(customer.name) (ID: \(customer.id), Phone: \(customer.phone))
        Vehicle  : \(vehicle.getDetails())
        Period   : \(formatter.string(from: startDate)) -> \(formatter.string(from: endDate)) (\(durationDays) day(s))
        Total Cost: $\(String(format: "%.2f", totalCost))
        ------------------------------------------------------------
        """
    }
}
