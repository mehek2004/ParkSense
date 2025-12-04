
import Foundation

class CacheService {
    static let shared = CacheService()

    private let userDefaults = UserDefaults.standard
    private let cacheValidityDuration: TimeInterval = 30 * 60 

    private enum CacheKey: String {
        case garageList = "cached_garage_list"
        case garageAvailability = "cached_garage_availability_"
        case lastCacheTime = "last_cache_time_"
    }

    private init() {}


    func isCacheValid(for key: String) -> Bool {
        let cacheTimeKey = CacheKey.lastCacheTime.rawValue + key
        guard let lastCacheTime = userDefaults.object(forKey: cacheTimeKey) as? Date else {
            return false
        }

        let timeSinceCache = Date().timeIntervalSince(lastCacheTime)
        return timeSinceCache < cacheValidityDuration
    }

    func getCacheAge(for key: String) -> TimeInterval? {
        let cacheTimeKey = CacheKey.lastCacheTime.rawValue + key
        guard let lastCacheTime = userDefaults.object(forKey: cacheTimeKey) as? Date else {
            return nil
        }

        return Date().timeIntervalSince(lastCacheTime)
    }

    private func updateCacheTime(for key: String) {
        let cacheTimeKey = CacheKey.lastCacheTime.rawValue + key
        userDefaults.set(Date(), forKey: cacheTimeKey)
    }


    func cache<T: Codable>(_ data: T, forKey key: String) {
        do {
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(data)
            userDefaults.set(encodedData, forKey: key)
            updateCacheTime(for: key)
        } catch {
            print("Error caching data for key \(key): \(error)")
        }
    }

    func retrieve<T: Codable>(forKey key: String, as type: T.Type) -> T? {
        guard let data = userDefaults.data(forKey: key) else {
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            print("Error retrieving cached data for key \(key): \(error)")
            return nil
        }
    }

    func clearCache(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        let cacheTimeKey = CacheKey.lastCacheTime.rawValue + key
        userDefaults.removeObject(forKey: cacheTimeKey)
    }


    func cacheGarageList(_ garages: [ParkingGarage]) {
        cache(garages, forKey: CacheKey.garageList.rawValue)
    }

    func getCachedGarageList() -> [ParkingGarage]? {
        guard isCacheValid(for: CacheKey.garageList.rawValue) else {
            return nil
        }
        return retrieve(forKey: CacheKey.garageList.rawValue, as: [ParkingGarage].self)
    }


    func cacheGarageAvailability(_ availability: GarageAvailability, garageId: Int) {
        let key = CacheKey.garageAvailability.rawValue + "\(garageId)"
        cache(availability, forKey: key)
    }

    func getCachedGarageAvailability(garageId: Int) -> GarageAvailability? {
        let key = CacheKey.garageAvailability.rawValue + "\(garageId)"
        guard isCacheValid(for: key) else {
            return nil
        }
        return retrieve(forKey: key, as: GarageAvailability.self)
    }

    func getGarageAvailabilityCacheAge(garageId: Int) -> TimeInterval? {
        let key = CacheKey.garageAvailability.rawValue + "\(garageId)"
        return getCacheAge(for: key)
    }


    func clearAllCache() {
    
        clearCache(forKey: CacheKey.garageList.rawValue)

        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix(CacheKey.garageAvailability.rawValue) ||
               key.hasPrefix(CacheKey.lastCacheTime.rawValue) {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}
