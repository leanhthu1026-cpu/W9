import Foundation

enum RentalError: Error, CustomStringConvertible {
    case vehicleNotFound(String)
    case customerNotFound(String)
    case vehicleUnavailable(String)
    case invalidDuration(Int)
    case rentalNotFound(String)
    case rentalAlreadyCompleted(String)
    case duplicateID(String)

    var description: String {
        switch self {
        case .vehicleNotFound(let id):
            return "❌ Error: Vehicle with ID '\(id)' was not found."
        case .customerNotFound(let id):
            return "❌ Error: Customer with ID '\(id)' was not found."
        case .vehicleUnavailable(let id):
            return "❌ Error: Vehicle '\(id)' is currently rented out and unavailable."
        case .invalidDuration(let days):
            return "❌ Error: Rental duration (\(days) days) must be at least 1 day."
        case .rentalNotFound(let id):
            return "❌ Error: Rental record '\(id)' was not found."
        case .rentalAlreadyCompleted(let id):
            return "❌ Error: Rental '\(id)' has already been returned."
        case .duplicateID(let id):
            return "❌ Error: Record with ID '\(id)' already exists."
        }
    }
}
