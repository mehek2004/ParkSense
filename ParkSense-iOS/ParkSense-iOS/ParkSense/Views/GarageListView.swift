
import SwiftUI

struct GarageListView: View {
    @EnvironmentObject var viewModel: GarageViewModel

    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading && viewModel.garages.isEmpty {
                    ProgressView("Loading garages...")
                        .tint(Color.sjsuBlue)
                } else if let error = viewModel.errorMessage, viewModel.garages.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(Color.sjsuGold)

                        Text("Error Loading Data")
                            .font(.headline)

                        Text(error)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        Button("Retry") {
                            Task {
                                await viewModel.loadGarages(forceRefresh: true)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color.sjsuBlue)
                    }
                } else {
                    List {
                        Section {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("SJSU")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(Color.sjsuBlue)

                                    Text("Parking")
                                        .font(.system(size: 32, weight: .light))
                                        .foregroundColor(Color.sjsuGold)
                                }

                                Text("Find available parking spots in real-time")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }

                        if viewModel.isOfflineMode {
                            Section {
                                HStack {
                                    Image(systemName: "wifi.slash")
                                        .foregroundColor(Color.sjsuGold)
                                    Text("Offline Mode - Showing cached data")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Section("Campus Parking Garages") {
                            ForEach(viewModel.garages) { garage in
                                NavigationLink(destination: GarageDetailView(garage: garage)) {
                                    GarageRowView(garage: garage)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("SJSU Parking")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refreshData()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color.sjsuBlue)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .task {
                if viewModel.garages.isEmpty {
                    await viewModel.loadGarages()
                }
            }
            .accentColor(Color.sjsuBlue)
        }
        .accentColor(Color.sjsuBlue)
    }
}

struct GarageRowView: View {
    let garage: ParkingGarage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(garage.name)
                .font(.headline)

            Text(garage.address)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 12, height: 12)

                Text("\(garage.openSpaces) / \(garage.totalSpaces) spots available")
                    .font(.subheadline)

                Spacer()

                Text("\(Int(garage.availabilityPercentage))%")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }

            Text("\(garage.totalFloors) floors")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
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

struct GarageListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = GarageViewModel()
        GarageListView()
            .environmentObject(viewModel)
    }
}
