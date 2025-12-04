
import Foundation

struct ParkingGarage: Codable, Identifiable {
    let garageId: Int
    let name: String
    let address: String
    let totalFloors: Int
    let totalSpaces: Int
    let openSpaces: Int
    let latitude: Double?
    let longitude: Double?
    let createdAt: String
    let updatedAt: String

    var id: Int { garageId }

    enum CodingKeys: String, CodingKey {
        case garageId = "garage_id"
        case name
        case address
        case totalFloors = "total_floors"
        case totalSpaces = "total_spaces"
        case openSpaces = "open_spaces"
        case latitude
        case longitude
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    var occupancyRate: Double {
        guard totalSpaces > 0 else { return 0.0 }
        let occupiedSpaces = totalSpaces - openSpaces
        return Double(occupiedSpaces) / Double(totalSpaces)
    }

    var availabilityPercentage: Double {
        guard totalSpaces > 0 else { return 0.0 }
        return Double(openSpaces) / Double(totalSpaces) * 100
    }

    var statusColor: String {
        let percentage = availabilityPercentage
        if percentage >= 30 {
            return "green"
        } else if percentage >= 10 {
            return "yellow"
        } else {
            return "red"
        }
    }
}
