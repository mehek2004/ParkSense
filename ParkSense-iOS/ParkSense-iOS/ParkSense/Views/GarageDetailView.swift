
import SwiftUI

struct GarageDetailView: View {
    let garage: ParkingGarage
    @EnvironmentObject var viewModel: GarageViewModel

    var body: some View {
        ZStack {
            if viewModel.isLoading && viewModel.garageAvailability == nil {
                ProgressView("Loading availability...")
            } else if let error = viewModel.errorMessage, viewModel.garageAvailability == nil {
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
                            await viewModel.loadGarageAvailability(
                                garageId: garage.id,
                                forceRefresh: true
                            )
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else if let availability = viewModel.garageAvailability {
                List {
                    if viewModel.isOfflineMode {
                        Section {
                            HStack {
                                Image(systemName: "wifi.slash")
                                    .foregroundColor(Color.sjsuGold)
                                VStack(alignment: .leading) {
                                    Text("Offline Mode")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    if let cacheAge = viewModel.formattedCacheAge() {
                                        Text("Data from \(cacheAge)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }

                    Section("Summary") {
                        GarageSummaryView(garage: availability.garage)
                    }

                    Section("Floors") {
                        ForEach(availability.floors) { floor in
                            NavigationLink(destination: FloorMapView(floor: floor)) {
                                FloorRowView(floor: floor)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle(garage.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        await viewModel.loadGarageAvailability(
                            garageId: garage.id,
                            forceRefresh: true
                        )
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.sjsuBlue)
                }
                .disabled(viewModel.isLoading)
            }
        }
        .task {
            if viewModel.garageAvailability == nil ||
               viewModel.garageAvailability?.garage.id != garage.id {
                await viewModel.loadGarageAvailability(garageId: garage.id)
            }
        }
    }
}

struct GarageSummaryView: View {
    let garage: ParkingGarage

    var body: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Availability")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(garage.availabilityPercentage))%")
                        .font(.headline)
                        .foregroundColor(statusColor)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        Rectangle()
                            .fill(statusColor)
                            .frame(
                                width: geometry.size.width * (garage.availabilityPercentage / 100),
                                height: 8
                            )
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }

            Divider()

            HStack(spacing: 20) {
                StatView(
                    title: "Available",
                    value: "\(garage.openSpaces)",
                    color: .parkingAvailable
                )

                Divider()

                StatView(
                    title: "Occupied",
                    value: "\(garage.totalSpaces - garage.openSpaces)",
                    color: Color.sjsuGray
                )

                Divider()

                StatView(
                    title: "Total",
                    value: "\(garage.totalSpaces)",
                    color: Color.sjsuBlue
                )
            }
            .frame(height: 60)
        }
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch garage.statusColor {
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

struct StatView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct FloorRowView: View {
    let floor: GarageAvailability.FloorData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Floor \(floor.floorNumber)")
                    .font(.headline)

                Spacer()

                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)
            }

            HStack {
                Text("\(floor.availableSpots) available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text("\(floor.availableSpots) / \(floor.totalSpots)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 6)
                        .cornerRadius(3)

                    Rectangle()
                        .fill(statusColor)
                        .frame(
                            width: geometry.size.width * availabilityPercentage,
                            height: 6
                        )
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 4)
    }

    private var availabilityPercentage: Double {
        guard floor.totalSpots > 0 else { return 0.0 }
        return Double(floor.availableSpots) / Double(floor.totalSpots)
    }

    private var statusColor: Color {
        let percentage = availabilityPercentage * 100
        if percentage >= 30 {
            return .green
        } else if percentage >= 10 {
            return .orange
        } else {
            return .red
        }
    }
}

struct GarageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GarageViewModel()
        let garage = ParkingGarage(
            garageId: 1,
            name: "Main Campus Garage",
            address: "123 University Ave",
            totalFloors: 3,
            totalSpaces: 150,
            openSpaces: 75,
            latitude: 37.7749,
            longitude: -122.4194,
            createdAt: "",
            updatedAt: ""
        )

        NavigationView {
            GarageDetailView(garage: garage)
                .environmentObject(viewModel)
        }
    }
}
