
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
    private let totalAisles = 8
    private let wallSpotsPerSection = 8             
    private let middleSpotsPerRow = 10          
    private let topBottomSpots = 20               

    var body: some View {
        ZStack(alignment: .trailing) {
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    ForEach(getTopBottomSpots(isTop: true)) { spot in
                        ParkingSpotView(spot: spot, orientation: .horizontal)
                    }
                }
                .frame(height: 11)
                .padding(4)
                .background(Color.white.opacity(0.5))

                ForEach(0..<totalAisles, id: \.self) { aisleIndex in
    
                    GarageAisleSection(
                        leftWallSpots: getSpots(for: aisleIndex, section: .leftWall),
                        rightWallSpots: getSpots(for: aisleIndex, section: .rightWall),
                        topMiddleSpots: getSpots(for: aisleIndex, section: .topMiddle),
                        bottomMiddleSpots: getSpots(for: aisleIndex, section: .bottomMiddle),
                        aisleNumber: aisleIndex + 1,
                        isGapRow: aisleIndex == 3 
                    )
                    .id(aisleIndex)
                }

                HStack(spacing: 0) {
                    ForEach(getTopBottomSpots(isTop: false)) { spot in
                        ParkingSpotView(spot: spot, orientation: .horizontal)
                    }
                }
                .frame(height: 11)
                .padding(4)
                .background(Color.white.opacity(0.5))
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)

            VStack(alignment: .trailing, spacing: 0) {
                Spacer()
                    .frame(height: calculateOffsetForAisle(2))

                EntranceExitIndicator(type: .entrance)
                    .padding(.trailing, -5)

                Spacer()
                    .frame(height: calculateOffsetForAisle(5) - calculateOffsetForAisle(2) - 20)

                EntranceExitIndicator(type: .exit)
                    .padding(.trailing, -5)

                Spacer()
            }
        }
    }

    private func calculateOffsetForAisle(_ aisleIndex: Int) -> CGFloat {
        let topRowHeight: CGFloat = 11 + 8 
        let aisleHeight: CGFloat = 136 

        var offset = topRowHeight
        offset += (aisleHeight * CGFloat(aisleIndex))
        return offset + 68 
    }

    private func getTopBottomSpots(isTop: Bool) -> [ParkingSpot] {
        
        let fullAisleSpots = wallSpotsPerSection * 2 + middleSpotsPerRow * 2 
        let partialAisleSpots = wallSpotsPerSection + middleSpotsPerRow * 2 
        let totalAisleSpots = (fullAisleSpots * 2) + (partialAisleSpots * 4) + (fullAisleSpots * 2)

        if isTop {
            let startIndex = totalAisleSpots
            let endIndex = min(startIndex + topBottomSpots, spots.count)
            guard startIndex < spots.count else { return [] }
            return Array(spots[startIndex..<endIndex])
        } else {
            let startIndex = totalAisleSpots + topBottomSpots
            let endIndex = min(startIndex + topBottomSpots, spots.count)
            guard startIndex < spots.count else { return [] }
            return Array(spots[startIndex..<endIndex])
        }
    }

    private func getSpots(for aisleIndex: Int, section: ParkingSection) -> [ParkingSpot] {

        var baseIndex = 0
        let fullAisleSpots = wallSpotsPerSection * 2 + middleSpotsPerRow * 2 
        let partialAisleSpots = wallSpotsPerSection + middleSpotsPerRow * 2 

        for i in 0..<aisleIndex {
            if i >= 2 && i <= 5 {
              
                baseIndex += partialAisleSpots
            } else {
                baseIndex += fullAisleSpots
            }
        }

       
        if section == .rightWall && aisleIndex >= 2 && aisleIndex <= 5 {
            return []
        }

        let startIndex: Int
        let count: Int

        switch section {
        case .leftWall:
            startIndex = baseIndex
            count = wallSpotsPerSection
        case .topMiddle:
            startIndex = baseIndex + wallSpotsPerSection
            count = middleSpotsPerRow
        case .bottomMiddle:
            startIndex = baseIndex + wallSpotsPerSection + middleSpotsPerRow
            count = middleSpotsPerRow
        case .rightWall:
            startIndex = baseIndex + wallSpotsPerSection + middleSpotsPerRow * 2
            count = wallSpotsPerSection
        }

        let endIndex = min(startIndex + count, spots.count)
        guard startIndex < spots.count else { return [] }
        return Array(spots[startIndex..<endIndex])
    }

    enum ParkingSection {
        case leftWall, rightWall, topMiddle, bottomMiddle
    }
}

struct EntranceExitIndicator: View {
    let type: IndicatorType

    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: type == .entrance ? "arrow.down" : "arrow.up")
                .font(.system(size: 8))
                .foregroundColor(.white)
            Text(type == .entrance ? "IN" : "OUT")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(type == .entrance ? Color.sjsuBlue : Color.sjsuGold)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
    }

    enum IndicatorType {
        case entrance, exit
    }
}

struct GarageAisleSection: View {
    let leftWallSpots: [ParkingSpot]
    let rightWallSpots: [ParkingSpot]
    let topMiddleSpots: [ParkingSpot]
    let bottomMiddleSpots: [ParkingSpot]
    let aisleNumber: Int
    let isGapRow: Bool

    var body: some View {
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(leftWallSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .perpendicular)
                        .frame(height: 15)
                }
            }
            .frame(width: 50)

            Rectangle()
                .fill(Color.clear)
                .frame(width: 16)

            VStack(spacing: 2) {
                if !topMiddleSpots.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(topMiddleSpots) { spot in
                            ParkingSpotView(spot: spot, orientation: .horizontal)
                        }
                    }
                    .frame(height: 25)
                }

                Rectangle()
                    .fill(isGapRow ? Color.gray.opacity(0.2) : Color.gray.opacity(0.12))
                    .frame(height: 16)

                if !bottomMiddleSpots.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(bottomMiddleSpots) { spot in
                            ParkingSpotView(spot: spot, orientation: .horizontal)
                        }
                    }
                    .frame(height: 25)
                }
            }

            Rectangle()
                .fill(Color.clear)
                .frame(width: 8)

            VStack(spacing: 0) {
                ForEach(rightWallSpots) { spot in
                    ParkingSpotView(spot: spot, orientation: .perpendicular)
                        .frame(height: 15)
                }
            }
            .frame(width: 50)
        }
        .frame(height: 136)
        .background(Color.white.opacity(0.5))
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
        case horizontal, perpendicular
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
