import SwiftUI

extension Color {
    static let sjsuBlue = Color(red: 0/255, green: 85/255, blue: 162/255)             
    static let sjsuGold = Color(red: 229/255, green: 168/255, blue: 35/255)           
    static let sjsuGray = Color(red: 147/255, green: 149/255, blue: 151/255)          

    static let sjsuLightGray = Color(red: 210/255, green: 210/255, blue: 210/255)     
    static let sjsuDarkGray = Color(red: 102/255, green: 102/255, blue: 102/255)     

    static let parkingAvailable = Color.green
    static let parkingLimited = Color.orange
    static let parkingFull = Color.red
}

struct SJSUTheme {
    static let primaryAccent = Color.sjsuBlue
    static let secondaryAccent = Color.sjsuGold

    static func availabilityColor(percentage: Double) -> Color {
        if percentage >= 30 {
            return .parkingAvailable
        } else if percentage >= 10 {
            return .parkingLimited
        } else {
            return .parkingFull
        }
    }

    static func availabilityColorName(percentage: Double) -> String {
        if percentage >= 30 {
            return "green"
        } else if percentage >= 10 {
            return "yellow"
        } else {
            return "red"
        }
    }
}
