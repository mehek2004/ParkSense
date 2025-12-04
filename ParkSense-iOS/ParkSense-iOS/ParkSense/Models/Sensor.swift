
import Foundation

struct Sensor: Codable, Identifiable {
    let sensorId: Int
    let parkingSpaceId: Int
    let sensorType: String
    let status: String
    let lastReading: Double?
    let batteryLevel: Int
    let lastPing: String

    var id: Int { sensorId }

    enum CodingKeys: String, CodingKey {
        case sensorId = "sensor_id"
        case parkingSpaceId = "parking_space_id"
        case sensorType = "sensor_type"
        case status
        case lastReading = "last_reading"
        case batteryLevel = "battery_level"
        case lastPing = "last_ping"
    }

    var batteryStatus: BatteryStatus {
        if batteryLevel >= 70 {
            return .good
        } else if batteryLevel >= 20 {
            return .low
        } else {
            return .critical
        }
    }

    var batteryColor: String {
        switch batteryStatus {
        case .good:
            return "green"
        case .low:
            return "yellow"
        case .critical:
            return "red"
        }
    }

    var batteryIcon: String {
        switch batteryStatus {
        case .good:
            return "battery.100"
        case .low:
            return "battery.25"
        case .critical:
            return "battery.0"
        }
    }

    var isHealthy: Bool {
        return status == "active" && batteryLevel >= 20
    }

    enum BatteryStatus {
        case good
        case low
        case critical
    }
}

struct SensorStatus: Codable {
    let sensorId: Int
    let parkingSpaceId: Int
    let sensorType: String
    let status: String
    let lastReading: Double?
    let batteryLevel: Int
    let lastPing: String
    let isResponsive: Bool
    let timeSincePing: Double

    enum CodingKeys: String, CodingKey {
        case sensorId = "sensor_id"
        case parkingSpaceId = "parking_space_id"
        case sensorType = "sensor_type"
        case status
        case lastReading = "last_reading"
        case batteryLevel = "battery_level"
        case lastPing = "last_ping"
        case isResponsive = "is_responsive"
        case timeSincePing = "time_since_ping"
    }
}

struct SensorHealth: Codable {
    let totalSensors: Int
    let healthy: Int
    let lowBattery: Int
    let unresponsive: Int
    let sensors: SensorCategories

    enum CodingKeys: String, CodingKey {
        case totalSensors = "total_sensors"
        case healthy
        case lowBattery = "low_battery"
        case unresponsive
        case sensors
    }

    struct SensorCategories: Codable {
        let healthy: [SensorStatus]
        let lowBattery: [SensorStatus]
        let unresponsive: [SensorStatus]

        enum CodingKeys: String, CodingKey {
            case healthy
            case lowBattery = "low_battery"
            case unresponsive
        }
    }
}
