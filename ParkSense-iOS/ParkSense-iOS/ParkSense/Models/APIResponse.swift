
import Foundation

struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T?
    let error: String?
    let count: Int?
}

struct APIErrorResponse: Codable { 
    let success: Bool
    let error: String
}

typealias GarageListResponse = APIResponse<[ParkingGarage]>
typealias GarageResponse = APIResponse<ParkingGarage>
typealias GarageAvailabilityResponse = APIResponse<GarageAvailability>
typealias FloorAvailabilityResponse = APIResponse<FloorAvailability>
typealias SpotListResponse = APIResponse<[ParkingSpot]>
typealias SpotResponse = APIResponse<ParkingSpot>
typealias SensorHealthResponse = APIResponse<SensorHealth>
typealias SensorStatusResponse = APIResponse<SensorStatus>
