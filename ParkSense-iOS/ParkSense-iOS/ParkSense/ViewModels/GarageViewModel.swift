
import Foundation
import Combine

@MainActor
class GarageViewModel: ObservableObject {
    @Published var garages: [ParkingGarage] = []
    @Published var selectedGarage: ParkingGarage?
    @Published var garageAvailability: GarageAvailability?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isOfflineMode = false
    @Published var cacheAge: TimeInterval?

    private let apiService = APIService.shared
    private let cacheService = CacheService.shared


    func loadGarages(forceRefresh: Bool = false) async {
        
        if !forceRefresh, let cachedGarages = cacheService.getCachedGarageList() {
            garages = cachedGarages
            isOfflineMode = true
            return
        }

        isLoading = true
        errorMessage = nil
        isOfflineMode = false

        do {
            let fetchedGarages = try await apiService.getAllGarages()
            garages = fetchedGarages

            cacheService.cacheGarageList(fetchedGarages)

        } catch {
            errorMessage = error.localizedDescription

            if let cachedGarages = cacheService.getCachedGarageList() {
                garages = cachedGarages
                isOfflineMode = true
            }
        }

        isLoading = false
    }

    func loadGarageAvailability(garageId: Int, forceRefresh: Bool = false) async {
        if !forceRefresh,
           let cachedAvailability = cacheService.getCachedGarageAvailability(garageId: garageId) {
            garageAvailability = cachedAvailability
            cacheAge = cacheService.getGarageAvailabilityCacheAge(garageId: garageId)
            isOfflineMode = true
            return
        }

        isLoading = true
        errorMessage = nil
        isOfflineMode = false
        cacheAge = nil

        do {
            let availability = try await apiService.getGarageAvailability(garageId: garageId)
            garageAvailability = availability
            selectedGarage = availability.garage

            cacheService.cacheGarageAvailability(availability, garageId: garageId)

        } catch {
            errorMessage = error.localizedDescription

            if let cachedAvailability = cacheService.getCachedGarageAvailability(garageId: garageId) {
                garageAvailability = cachedAvailability
                selectedGarage = cachedAvailability.garage
                cacheAge = cacheService.getGarageAvailabilityCacheAge(garageId: garageId)
                isOfflineMode = true
            }
        }

        isLoading = false
    }


    func loadFloorAvailability(garageId: Int, floorNumber: Int) async -> FloorAvailability? {
        do {
            let availability = try await apiService.getFloorAvailability(
                garageId: garageId,
                floorNumber: floorNumber
            )
            return availability
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }


    func loadSpotsByType(garageId: Int, spotType: String) async -> [ParkingSpot] {
        do {
            let spots = try await apiService.getSpotsByType(
                garageId: garageId,
                spotType: spotType
            )
            return spots
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }


    func selectGarage(_ garage: ParkingGarage) {
        selectedGarage = garage
    }

    func clearSelection() {
        selectedGarage = nil
        garageAvailability = nil
        cacheAge = nil
    }

    func refreshData() async {
        if let garage = selectedGarage {
            await loadGarageAvailability(garageId: garage.id, forceRefresh: true)
        } else {
            await loadGarages(forceRefresh: true)
        }
    }

    func clearCache() {
        cacheService.clearAllCache()
        isOfflineMode = false
        cacheAge = nil
    }

    func formattedCacheAge() -> String? {
        guard let age = cacheAge else { return nil }

        let minutes = Int(age / 60)
        if minutes < 1 {
            return "< 1 min ago"
        } else if minutes == 1 {
            return "1 min ago"
        } else {
            return "\(minutes) mins ago"
        }
    }
}
