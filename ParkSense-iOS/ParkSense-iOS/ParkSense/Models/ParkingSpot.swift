
import Foundation

struct ParkingSpot: Codable, Identifiable {
    let spaceId: Int
    let garageId: Int
    let floorNumber: Int
    let spotNumber: String
    let spotType: String
    let isOccupied: Bool
    let lastUpdated: String

    var id: Int { spaceId }

    enum CodingKeys: String, CodingKey {
        case spaceId = "space_id"
        case garageId = "garage_id"
        case floorNumber = "floor_number"
        case spotNumber = "spot_number"
        case spotType = "spot_type"
        case isOccupied = "is_occupied"
        case lastUpdated = "last_updated"
    }

    var spotLabel: String {
        return "\(floorNumber)-\(spotNumber)"
    }

    var typeDisplay: String {
        switch spotType {
        case "regular":
            return "Regular"
        case "handicap":
            return "Handicap"
        case "staff":
            return "Staff Only"
        case "ev":
            return "EV Charging"
        default:
            return spotType.capitalized
        }
    }

    var statusIcon: String {
        return isOccupied ? "xmark.circle.fill" : "checkmark.circle.fill"
    }

    var statusColor: String {
        return isOccupied ? "red" : "green"
    }
}

struct FloorAvailability: Codable {
    let floorNumber: Int
    let totalSpots: Int
    let availableSpots: Int
    let occupiedSpots: Int
    let available: [ParkingSpot]
    let occupied: [ParkingSpot]

    enum CodingKeys: String, CodingKey {
        case floorNumber = "floor_number"
        case totalSpots = "total_spots"
        case availableSpots = "available_spots"
        case occupiedSpots = "occupied_spots"
        case available
        case occupied
    }
}

struct GarageAvailability: Codable {
    let garage: ParkingGarage
    let floors: [FloorData]

    struct FloorData: Codable, Identifiable {
        let floorNumber: Int
        let totalSpots: Int
        let availableSpots: Int
        let occupiedSpots: Int
        let spots: [ParkingSpot]

        var id: Int { floorNumber }

        enum CodingKeys: String, CodingKey {
            case floorNumber = "floor_number"
            case totalSpots = "total_spots"
            case availableSpots = "available_spots"
            case occupiedSpots = "occupied_spots"
            case spots
        }
    }
}
