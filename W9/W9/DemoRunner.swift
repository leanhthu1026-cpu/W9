import Foundation

func runDemo() {
    let system = RentalSystem()

    print("--- 1. INITIALIZING SAMPLE VEHICLES (FR1) ---")
    do {
        let car1 = Car(id: "V01", brand: "Toyota", model: "Camry", dailyRate: 60.0, seatingCapacity: 5, insuranceAndCleaningFee: 25.0)
        let car2 = Car(id: "V02", brand: "Ford", model: "Explorer", dailyRate: 85.0, seatingCapacity: 7, insuranceAndCleaningFee: 35.0)
        let moto1 = Motorcycle(id: "V03", brand: "Yamaha", model: "MT-03", dailyRate: 35.0, engineCC: 321)
        let moto2 = Motorcycle(id: "V04", brand: "BMW", model: "R1250GS", dailyRate: 70.0, engineCC: 1254)
        let ebike1 = ElectricBicycle(id: "V05", brand: "Specialized", model: "Turbo Vado", dailyRate: 20.0, batteryRangeKm: 110, batteryFeePerDay: 4.0)

        try system.addVehicle(car1)
        try system.addVehicle(car2)
        try system.addVehicle(moto1)
        try system.addVehicle(moto2)
        try system.addVehicle(ebike1)

        try system.updateVehicleRate(id: "V01", newRate: 65.0)
        system.displayAllVehicles()

        print("--- 2. REGISTERING & UPDATING CUSTOMERS (FR2) ---")
        let cust1 = Customer(id: "C01", name: "Alice Nguyen", phone: "555-0101", email: "alice@example.com")
        let cust2 = Customer(id: "C02", name: "Marcus Vance", phone: "555-0202", email: "marcus@example.com")

        try system.registerCustomer(cust1)
        try system.registerCustomer(cust2)
        try system.updateCustomerContact(id: "C01", phone: "555-9999", email: nil)
        print(cust1.getInfo())

        print("\n--- 3. PROCESSING RENTALS & POLYMORPHIC PRICING (FR3, FR4, FR5) ---")
        let rental1 = try system.rentVehicle(customerId: "C01", vehicleId: "V01", days: 3)
        _ = try system.rentVehicle(customerId: "C02", vehicleId: "V03", days: 2)
        _ = try system.rentVehicle(customerId: "C01", vehicleId: "V05", days: 4)

        print("--- 4. TESTING INVALID OPERATIONS (ERROR HANDLING) ---")
        do {
            _ = try system.rentVehicle(customerId: "C02", vehicleId: "V01", days: 2)
        } catch {
            print(error)
        }

        do {
            _ = try system.rentVehicle(customerId: "C02", vehicleId: "V02", days: 0)
        } catch {
            print(error)
        }

        print("\n--- 5. RETURNING VEHICLE & CHECKING AVAILABILITY (FR1, FR3) ---")
        try system.returnVehicle(rentalId: rental1.rentalId)
        let isV01Available = try system.checkVehicleAvailability(id: "V01")
        print("Is V01 available now? \(isV01Available ? "Yes" : "No")")

        try system.viewCustomerRentalHistory(customerId: "C01")

    } catch {
        print("Unexpected error: \(error)")
    }
}
