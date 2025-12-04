
import Foundation
import Combine

@MainActor
class SensorViewModel: ObservableObject {
    @Published var sensorHealth: SensorHealth?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService = APIService.shared


    func loadSensorHealth() async {
        isLoading = true
        errorMessage = nil

        do {
            let health = try await apiService.getSensorHealth()
            sensorHealth = health
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }


    func getSensorStatus(sensorId: Int) async -> SensorStatus? {
        do {
            let status = try await apiService.getSensorStatus(sensorId: sensorId)
            return status
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }


    func refresh() async {
        await loadSensorHealth()
    }

    var healthPercentage: Double {
        guard let health = sensorHealth, health.totalSensors > 0 else {
            return 0.0
        }
        return Double(health.healthy) / Double(health.totalSensors) * 100
    }

    var hasIssues: Bool {
        guard let health = sensorHealth else {
            return false
        }
        return health.lowBattery > 0 || health.unresponsive > 0
    }

    var statusColor: String {
        let percentage = healthPercentage
        if percentage >= 90 {
            return "green"
        } else if percentage >= 70 {
            return "yellow"
        } else {
            return "red"
        }
    }
}
