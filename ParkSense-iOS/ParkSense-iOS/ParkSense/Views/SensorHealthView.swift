
import SwiftUI

struct SensorHealthView: View {
    @StateObject private var viewModel = SensorViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.sensorHealth == nil {
                    ProgressView("Loading sensor health...")
                } else if let error = viewModel.errorMessage, viewModel.sensorHealth == nil {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)

                        Text("Error Loading Data")
                            .font(.headline)

                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            Task {
                                await viewModel.loadSensorHealth()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if let health = viewModel.sensorHealth {
                    List {
                        Section("Overall Health") {
                            HealthSummaryView(
                                totalSensors: health.totalSensors,
                                healthy: health.healthy,
                                healthPercentage: viewModel.healthPercentage,
                                statusColor: viewModel.statusColor
                            )
                        }

                        Section("Status Breakdown") {
                            HealthBreakdownRow(
                                title: "Healthy",
                                count: health.healthy,
                                total: health.totalSensors,
                                color: .green,
                                icon: "checkmark.circle.fill"
                            )

                            HealthBreakdownRow(
                                title: "Low Battery",
                                count: health.lowBattery,
                                total: health.totalSensors,
                                color: .orange,
                                icon: "battery.25"
                            )

                            HealthBreakdownRow(
                                title: "Unresponsive",
                                count: health.unresponsive,
                                total: health.totalSensors,
                                color: .red,
                                icon: "wifi.slash"
                            )
                        }
                        if !health.sensors.lowBattery.isEmpty {
                            Section("Low Battery Sensors") {
                                ForEach(health.sensors.lowBattery, id: \.sensorId) { sensor in
                                    SensorRowView(sensor: sensor, issue: "low_battery")
                                }
                            }
                        }
                        if !health.sensors.unresponsive.isEmpty {
                            Section("Unresponsive Sensors") {
                                ForEach(health.sensors.unresponsive, id: \.sensorId) { sensor in
                                    SensorRowView(sensor: sensor, issue: "unresponsive")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Sensor Health")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                if viewModel.sensorHealth == nil {
                    await viewModel.loadSensorHealth()
                }
            }
        }
    }
}

struct HealthSummaryView: View {
    let totalSensors: Int
    let healthy: Int
    let healthPercentage: Double
    let statusColor: String

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: healthPercentage / 100)
                    .stroke(color, lineWidth: 15)
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(healthPercentage))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(color)

                    Text("Healthy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            HStack(spacing: 20) {
                VStack {
                    Text("\(healthy)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Healthy")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text("\(totalSensors - healthy)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Issues")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()
                    .frame(height: 40)

                VStack {
                    Text("\(totalSensors)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }

    private var color: Color {
        switch statusColor {
        case "green":
            return .green
        case "yellow":
            return .orange
        case "red":
            return .red
        default:
            return .gray
        }
    }
}

struct HealthBreakdownRow: View {
    let title: String
    let count: Int
    let total: Int
    let color: Color
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)

            Text(title)
                .font(.subheadline)

            Spacer()

            Text("\(count)")
                .font(.headline)
                .foregroundColor(color)

            Text("/ \(total)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct SensorRowView: View {
    let sensor: SensorStatus
    let issue: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Sensor #\(sensor.sensorId)")
                    .font(.headline)

                Spacer()

                if issue == "low_battery" {
                    HStack(spacing: 4) {
                        Image(systemName: "battery.25")
                            .foregroundColor(.orange)
                        Text("\(sensor.batteryLevel)%")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                } else if issue == "unresponsive" {
                    HStack(spacing: 4) {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.red)
                        Text("Offline")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                }
            }

            HStack {
                Text("Spot ID: \(sensor.parkingSpaceId)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Type: \(sensor.sensorType)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            if let lastReading = sensor.lastReading {
                Text("Last reading: \(String(format: "%.1f", lastReading)) cm")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct SensorHealthView_Previews: PreviewProvider {
    static var previews: some View {
        SensorHealthView()
    }
}
