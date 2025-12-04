
import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case noData

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Data parsing error: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .noData:
            return "No data received"
        }
    }
}

class APIService {
    static let shared = APIService()

    private let baseURL = "http://localhost:5000/api/v1"

    private let session: URLSession
    private let decoder: JSONDecoder

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }


    private func request<T: Codable>(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.noData
            }

            if httpResponse.statusCode >= 400 {
                if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                    throw APIError.serverError(errorResponse.error)
                } else {
                    throw APIError.serverError("HTTP \(httpResponse.statusCode)")
                }
            }

            let decodedResponse = try decoder.decode(T.self, from: data)
            return decodedResponse

        } catch let error as APIError {
            throw error
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }


    func getAllGarages() async throws -> [ParkingGarage] {
        let response: GarageListResponse = try await request(endpoint: "/garages")
        guard let garages = response.data else {
            throw APIError.noData
        }
        return garages
    }

    func getGarage(id: Int) async throws -> ParkingGarage {
        let response: GarageResponse = try await request(endpoint: "/garages/\(id)")
        guard let garage = response.data else {
            throw APIError.noData
        }
        return garage
    }

    func getGarageAvailability(garageId: Int) async throws -> GarageAvailability {
        let response: GarageAvailabilityResponse = try await request(
            endpoint: "/garages/\(garageId)/availability"
        )
        guard let availability = response.data else {
            throw APIError.noData
        }
        return availability
    }

    func getFloorAvailability(garageId: Int, floorNumber: Int) async throws -> FloorAvailability {
        let response: FloorAvailabilityResponse = try await request(
            endpoint: "/garages/\(garageId)/floors/\(floorNumber)"
        )
        guard let availability = response.data else {
            throw APIError.noData
        }
        return availability
    }

    func getSpotsByType(garageId: Int, spotType: String) async throws -> [ParkingSpot] {
        let response: SpotListResponse = try await request(
            endpoint: "/garages/\(garageId)/spots/type/\(spotType)"
        )
        guard let spots = response.data else {
            throw APIError.noData
        }
        return spots
    }


    func getSensorHealth() async throws -> SensorHealth {
        let response: SensorHealthResponse = try await request(
            endpoint: "/sensors/health"
        )
        guard let health = response.data else {
            throw APIError.noData
        }
        return health
    }

    func getSensorStatus(sensorId: Int) async throws -> SensorStatus {
        let response: SensorStatusResponse = try await request(
            endpoint: "/sensors/\(sensorId)"
        )
        guard let status = response.data else {
            throw APIError.noData
        }
        return status
    }


    func getSpot(spaceId: Int) async throws -> ParkingSpot {
        let response: SpotResponse = try await request(
            endpoint: "/spots/\(spaceId)"
        )
        guard let spot = response.data else {
            throw APIError.noData
        }
        return spot
    }

    func updateSpotOccupancy(spaceId: Int, isOccupied: Bool) async throws -> ParkingSpot {
        let body = ["is_occupied": isOccupied]
        let bodyData = try JSONEncoder().encode(body)

        let response: SpotResponse = try await request(
            endpoint: "/spots/\(spaceId)/occupancy",
            method: "PUT",
            body: bodyData
        )
        guard let spot = response.data else {
            throw APIError.noData
        }
        return spot
    }
}
