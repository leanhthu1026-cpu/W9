import Foundation

// Cấu trúc dữ liệu phục vụ báo cáo thống kê
struct DailyVehicleStatus: Identifiable {
    var id: String { vehicle.id }
    let vehicle: Vehicle
    let isAvailableOnDate: Bool
    let activeRental: Rental?
}

struct MonthlyRevenueReport {
    let month: Int
    let year: Int
    let carRevenue: Double
    let motorcycleRevenue: Double
    let eBikeRevenue: Double

    var totalRevenue: Double {
        carRevenue + motorcycleRevenue + eBikeRevenue
    }
}

class RentalSystem {
    private var vehicles: [String: Vehicle] = [:]
    private var customers: [String: Customer] = [:]
    private var rentals: [String: Rental] = [:]
    private var rentalCounter: Int = 1000

    var allVehicles: [Vehicle] {
        vehicles.values.sorted { $0.id < $1.id }
    }

    var allCustomers: [Customer] {
        customers.values.sorted { $0.id < $1.id }
    }

    var allRentals: [Rental] {
        rentals.values.sorted { $0.rentalId > $1.rentalId }
    }

    // MARK: - FR1: Vehicle Management
    func addVehicle(_ vehicle: Vehicle) throws {
        guard vehicles[vehicle.id] == nil else {
            throw RentalError.duplicateID(vehicle.id)
        }
        vehicles[vehicle.id] = vehicle
    }

    func getVehicle(byId id: String) throws -> Vehicle {
        guard let vehicle = vehicles[id] else {
            throw RentalError.vehicleNotFound(id)
        }
        return vehicle
    }

    func updateVehicleRate(id: String, newRate: Double) throws {
        let vehicle = try getVehicle(byId: id)
        vehicle.updateInfo(dailyRate: newRate)
    }

    func checkVehicleAvailability(id: String) throws -> Bool {
        let vehicle = try getVehicle(byId: id)
        return vehicle.isAvailable
    }

    func displayAllVehicles() {
        for vehicle in allVehicles {
            print(vehicle.getDetails())
        }
    }

    // MARK: - FR2: Customer Management
    func registerCustomer(_ customer: Customer) throws {
        guard customers[customer.id] == nil else {
            throw RentalError.duplicateID(customer.id)
        }
        customers[customer.id] = customer
    }

    func getCustomer(byId id: String) throws -> Customer {
        guard let customer = customers[id] else {
            throw RentalError.customerNotFound(id)
        }
        return customer
    }

    func updateCustomerContact(id: String, phone: String?, email: String?) throws {
        let customer = try getCustomer(byId: id)
        customer.updateContactInfo(phone: phone, email: email)
    }

    func viewCustomerRentalHistory(customerId: String) throws {
        let customer = try getCustomer(byId: customerId)
        for rental in customer.rentalHistory {
            print(rental.displaySummary())
        }
    }

    // MARK: - FR3: Rental Management
    @discardableResult
    func rentVehicle(customerId: String, vehicleId: String, days: Int, startDate: Date = Date()) throws -> Rental {
        guard days > 0 else {
            throw RentalError.invalidDuration(days)
        }
        let customer = try getCustomer(byId: customerId)
        let vehicle = try getVehicle(byId: vehicleId)

        // Kiểm tra trùng lịch thuê trong khoảng ngày yêu cầu
        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: startDate)
        for offset in 0..<days {
            if let checkDate = calendar.date(byAdding: .day, value: offset, to: normalizedStart) {
                let isBusy = rentals.values.contains { $0.vehicle.id == vehicleId && $0.covers(date: checkDate) }
                if isBusy {
                    throw RentalError.vehicleUnavailable(vehicleId)
                }
            }
        }

        rentalCounter += 1
        let rentalId = "RNT-\(rentalCounter)"
        let rental = Rental(rentalId: rentalId, customer: customer, vehicle: vehicle, startDate: normalizedStart, durationDays: days)

        if rental.covers(date: Date()) {
            vehicle.setAvailability(false)
        }
        customer.addRentalRecord(rental)
        rentals[rentalId] = rental
        return rental
    }

    func returnVehicle(rentalId: String) throws {
        guard let rental = rentals[rentalId] else {
            throw RentalError.rentalNotFound(rentalId)
        }
        guard rental.status == .active else {
            throw RentalError.rentalAlreadyCompleted(rentalId)
        }

        rental.completeRental()
        rental.vehicle.setAvailability(true)
    }

    // MARK: - THỐNG KÊ & BÁO CÁO (STATISTICS)

    /// 1. Thống kê tình trạng toàn bộ xe vào một ngày cụ thể
    func getDailyFleetStatus(for date: Date) -> [DailyVehicleStatus] {
        return allVehicles.map { vehicle in
            let matchedRental = rentals.values.first { $0.vehicle.id == vehicle.id && $0.covers(date: date) }
            return DailyVehicleStatus(
                vehicle: vehicle,
                isAvailableOnDate: matchedRental == nil,
                activeRental: matchedRental
            )
        }
    }

    /// 2. Lọc danh sách các xe còn trống vào một ngày cụ thể
    func getAvailableVehicles(on date: Date) -> [Vehicle] {
        return getDailyFleetStatus(for: date)
            .filter { $0.isAvailableOnDate }
            .map { $0.vehicle }
    }

    /// 3. Thống kê doanh thu theo tháng & năm, phân tách theo từng loại xe
    func getMonthlyRevenue(month: Int, year: Int) -> MonthlyRevenueReport {
        let calendar = Calendar.current
        var carTotal = 0.0
        var motoTotal = 0.0
        var eBikeTotal = 0.0

        for rental in rentals.values {
            let comps = calendar.dateComponents([.month, .year], from: rental.startDate)
            if comps.month == month && comps.year == year {
                if rental.vehicle is Car {
                    carTotal += rental.totalCost
                } else if rental.vehicle is Motorcycle {
                    motoTotal += rental.totalCost
                } else if rental.vehicle is ElectricBicycle {
                    eBikeTotal += rental.totalCost
                }
            }
        }

        return MonthlyRevenueReport(
            month: month,
            year: year,
            carRevenue: carTotal,
            motorcycleRevenue: motoTotal,
            eBikeRevenue: eBikeTotal
        )
    }
}
