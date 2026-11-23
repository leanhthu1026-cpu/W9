import Foundation

class Customer {
    let id: String
    private(set) var name: String
    private(set) var phone: String
    private(set) var email: String
    private(set) var rentalHistory: [Rental] = []

    init(id: String, name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }

    func updateContactInfo(phone: String? = nil, email: String? = nil) {
        if let phone = phone, !phone.isEmpty { self.phone = phone }
        if let email = email, !email.isEmpty { self.email = email }
    }

    func addRentalRecord(_ rental: Rental) {
        rentalHistory.append(rental)
    }

    func getInfo() -> String {
        return "[\(id)] \(name) | Phone: \(phone) | Email: \(email) | Total Rentals: \(rentalHistory.count)"
    }
}
