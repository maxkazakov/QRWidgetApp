
import Foundation
import MapKit
import SwiftUI

final class MapFormViewModel: ObservableObject {

    let locationManager = LocationManager()
    let locationData: Binding<LocationFormData>

    init(
        locationData: Binding<LocationFormData>
    ) {
        self.locationData = locationData
        locationManager.onLocationChanged = { [weak self] in
            self?.mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                latitudinalMeters: 200,
                longitudinalMeters: 200
            )
        }
    }

    @Published var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    {
        didSet {
            locationData.wrappedValue = .init(latitude: mapRegion.center.latitude, longitude: mapRegion.center.longitude)
        }
    }

    func locationButtonTapped() {
        locationManager.requestLocation()
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    var onLocationChanged: (CLLocationCoordinate2D) -> Void = { _ in }

    let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        onLocationChanged(location.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("locationManager.didFailWithError", error)
    }
}
