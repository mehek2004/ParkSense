
import SwiftUI

struct FloorMapView: View {
    let floor: GarageAvailability.FloorData

    @State private var selectedSpotType: String = "all"
    private let spotTypes = ["all", "regular", "handicap", "staff", "ev"]

    var body: some View {
        VStack(spacing: 0) {
            FloorSummaryHeader(floor: floor)

            Picker("Spot Type", selection: $selectedSpotType) {
                Text("All").tag("all")
                Text("Handicap").tag("handicap")
                Text("Staff").tag("staff")
                Text("EV").tag("ev")
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                ParkingGarageMapView(spots: filteredSpots)
                    .padding()
            }
        }
        .navigationTitle("Floor \(floor.floorNumber)")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var filteredSpots: [ParkingSpot] {
        if selectedSpotType == "all" {
            return floor.spots
        } else {
            return floor.spots.filter { $0.spotType == selectedSpotType }
        }
    }
}

struct FloorSummaryHeader: View {
    let floor: GarageAvailability.FloorData

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 20) {
                SummaryStatView(
                    title: "Available",
                    value: "\(floor.availableSpots)",
                    color: .green,
                    icon: "checkmark.circle.fill"
                )

                Divider()
                    .frame(height: 40)

                SummaryStatView(
                    title: "Occupied",
                    value: "\(floor.occupiedSpots)",
                    color: .red,
                    icon: "xmark.circle.fill"
                )

                Divider()
                    .frame(height: 40)

                SummaryStatView(
                    title: "Total",
                    value: "\(floor.totalSpots)",
                    color: .blue,
                    icon: "square.grid.2x2.fill"
                )
            }
            .padding()

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * availabilityPercentage)

                    Rectangle()
                        .fill(Color.red)
                }
            }
            .frame(height: 8)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var availabilityPercentage: Double {
        guard floor.totalSpots > 0 else { return 0.0 }
        return Double(floor.availableSpots) / Double(floor.totalSpots)
    }
}

struct SummaryStatView: View {
    let title: String
    let value: String
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ParkingGarageMapView: View {
    let spots: [ParkingSpot]

    var body: some View {
        VStack(spacing: 0) {
            AngledWallSection(spots: getTopWallSpots(), isTop: true)

            HStack(spacing: 0) {
                Color.clear
                    .frame(width: 50)

                Color.clear
                    .frame(width: 16)

                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 22)

                Color.clear
                    .frame(width: 16)

                Color.clear
                    .frame(width: 50)
            }

            HStack(spacing: 0) {
                LeftWallSection(spots: getLeftWallSpots())

                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 16)

                MiddleSection(getRowSpots: getMiddleRowSpots)

                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 16)

                RightWallSection(
                    topSpots: getRightWallTopSpots(),
                    bottomSpots: getRightWallBottomSpots()
                )
            }

            AngledWallSection(spots: getBottomWallSpots(), isTop: false)
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func getTopWallSpots() -> [ParkingSpot] {
        let startIndex = 0
        let endIndex = min(startIndex + 27, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    private func getLeftWallSpots() -> [ParkingSpot] {
        let startIndex = 27
        let endIndex = min(startIndex + 42, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    private func getRightWallTopSpots() -> [ParkingSpot] {
        let startIndex = 69
        let endIndex = min(startIndex + 14, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    private func getRightWallBottomSpots() -> [ParkingSpot] {
        let startIndex = 83
        let endIndex = min(startIndex + 14, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    private func getMiddleRowSpots(rowNumber: Int) -> [ParkingSpot] {
        let startIndex = 97 + (rowNumber * 22)
        let endIndex = min(startIndex + 22, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    private func getBottomWallSpots() -> [ParkingSpot] {
        let startIndex = 361
        let endIndex = min(startIndex + 27, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }
}

struct AngledWallSection: View {
    let spots: [ParkingSpot]
    let isTop: Bool

    var body: some View {
        HStack(spacing: 0) {
            ForEach(spots) { spot in
                ParkingSpotView(spot: spot, orientation: .angled)
                    .frame(width: 14, height: 28)
                    .rotationEffect(.degrees(45))
            }
        }
        .frame(height: 35)
        .padding(.vertical, 4)
        .background(Color.white.opacity(0.5))
    }
}

struct LeftWallSection: View {
    let spots: [ParkingSpot]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(spots) { spot in
                ParkingSpotView(spot: spot, orientation: .perpendicular)
                    .frame(width: 50, height: 15)
            }
        }
        .frame(width: 50)
    }
}

struct RightWallSection: View {
    let topSpots: [ParkingSpot]
    let bottomSpots: [ParkingSpot]

    private let spotHeight: CGFloat = 15

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(topSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .perpendicular)
                        .frame(width: 50, height: spotHeight)
                }
            }
            .frame(height: spotHeight * 14)

            Spacer()
                .frame(height: spotHeight * 14)

            VStack(spacing: 0) {
                ForEach(bottomSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .perpendicular)
                        .frame(width: 50, height: spotHeight)
                }
            }
            .frame(height: spotHeight * 14)
        }
        .frame(width: 50)
    }
}

struct MiddleSection: View {
    let getRowSpots: (Int) -> [ParkingSpot]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(0..<6, id: \.self) { segmentIndex in
                SegmentView(
                    topRowSpots: getRowSpots(segmentIndex * 2),
                    bottomRowSpots: getRowSpots(segmentIndex * 2 + 1),
                    segmentNumber: segmentIndex
                )
            }
        }
    }
}

struct SegmentView: View {
    let topRowSpots: [ParkingSpot]
    let bottomRowSpots: [ParkingSpot]
    let segmentNumber: Int

    var body: some View {
        VStack(spacing: 3) {
            HStack(spacing: 0) {
                ForEach(topRowSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .horizontal)
                }
            }
            .frame(height: 35)

            HStack(spacing: 0) {
                ForEach(bottomRowSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .horizontal)
                }
            }
            .frame(height: 35)

            Rectangle()
                .fill(Color.clear)
                .frame(height: 22)
        }
    }
}

struct ParkingSpotView: View {
    let spot: ParkingSpot
    let orientation: SpotOrientation

    var body: some View {
        Rectangle()
            .fill(backgroundColor)
            .overlay(
                Group {
                    if spot.isOccupied {
                        Image(systemName: "car.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.white)
                    } else if spot.spotType != "regular" {
                        Image(systemName: spotTypeIcon)
                            .font(.system(size: 6))
                            .foregroundColor(spotTypeColor)
                    }
                }
            )
            .overlay(
                Rectangle()
                    .stroke(borderColor, lineWidth: 0.5)
            )
            .frame(maxWidth: .infinity)
    }

    private var backgroundColor: Color {
        if spot.isOccupied {
            return Color.red.opacity(0.85)
        } else {
            return Color.green.opacity(0.35)
        }
    }

    private var borderColor: Color {
        if spot.isOccupied {
            return Color.red.opacity(0.9)
        } else {
            return Color.green.opacity(0.6)
        }
    }

    private var spotTypeIcon: String {
        switch spot.spotType {
        case "handicap":
            return "figure.roll"
        case "staff":
            return "person.badge.key.fill"
        case "ev":
            return "bolt.fill"
        default:
            return "parkingsign"
        }
    }

    private var spotTypeColor: Color {
        switch spot.spotType {
        case "handicap":
            return .blue
        case "staff":
            return .orange
        case "ev":
            return Color.sjsuBlue
        default:
            return .gray
        }
    }

    enum SpotOrientation {
        case horizontal     
        case perpendicular  
        case angled         
    }
}

struct FloorMapView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleFloor = GarageAvailability.FloorData(
            floorNumber: 1,
            totalSpots: 50,
            availableSpots: 25,
            occupiedSpots: 25,
            spots: [
                ParkingSpot(
                    spaceId: 1,
                    garageId: 1,
                    floorNumber: 1,
                    spotNumber: "1",
                    spotType: "regular",
                    isOccupied: false,
                    lastUpdated: ""
                ),
                ParkingSpot(
                    spaceId: 2,
                    garageId: 1,
                    floorNumber: 1,
                    spotNumber: "2",
                    spotType: "handicap",
                    isOccupied: true,
                    lastUpdated: ""
                )
            ]
        )

        NavigationView {
            FloorMapView(floor: sampleFloor)
        }
    }
}
