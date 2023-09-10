
import SwiftUI
import MapKit
import CoreLocationUI

struct MapFormView: View {

    @StateObject var viewModel: MapFormViewModel

    var body: some View {
        ZStack {
            Map(
                coordinateRegion: $viewModel.mapRegion
            )
            .ignoresSafeArea(edges: .bottom)
            Image(systemName: "mappin")
                .foregroundColor(.red)
                .imageScale(.large)
            VStack {
                Spacer()
                LocationButton(.currentLocation) {
                    viewModel.locationButtonTapped()
                }
                .foregroundColor(.white)
                .symbolVariant(.fill)
                .labelStyle(.titleAndIcon)
                .cornerRadius(20)
            }
            .padding()
        }
    }
}

struct MapFormView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MapFormView(
                viewModel: MapFormViewModel(
                    locationData: .constant(.init(latitude: 50, longitude: 50))
                )
            )
        }
    }
}
