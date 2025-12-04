
import SwiftUI

struct ContentView: View {
    @StateObject private var garageViewModel = GarageViewModel()

    var body: some View {
        GarageListView()
            .environmentObject(garageViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
