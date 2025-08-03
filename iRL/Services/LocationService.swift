import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isLocationEnabled: Bool = false
    @Published var isWithinVisibilityRadius: Bool = false
    
    private var locationUpdateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        setupLocationManager()
        setupBindings()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // Battery efficient
        locationManager.distanceFilter = 50 // Update only when moving 50+ meters
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    private func setupBindings() {
        $currentLocation
            .combineLatest($authorizationStatus)
            .map { location, status in
                location != nil && status == .authorizedWhenInUse
            }
            .assign(to: \.isLocationEnabled, on: self)
            .store(in: &cancellables)
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse else {
            requestLocationPermission()
            return
        }
        
        locationManager.startUpdatingLocation()
        startPeriodicUpdates()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
        locationUpdateTimer?.invalidate()
        locationUpdateTimer = nil
    }
    
    private func startPeriodicUpdates() {
        // Only update location every 30 seconds to save battery
        locationUpdateTimer = Timer.scheduledTimer(withTimeInterval: AppConstants.locationUpdateInterval, repeats: true) { [weak self] _ in
            self?.locationManager.requestLocation()
        }
    }
    
    func isWithinRadius(of location: CLLocation, radius: CLLocationDistance) -> Bool {
        guard let currentLocation = currentLocation else { return false }
        return currentLocation.distance(from: location) <= radius
    }
    
    func checkVisibilityRadius() {
        guard let currentLocation = currentLocation else { return }
        
        // For demo purposes, we'll use a fixed reference point
        // In a real app, this would check against saved frequent places
        let demoLocation = CLLocation(latitude: 37.7749, longitude: -122.4194) // San Francisco
        isWithinVisibilityRadius = isWithinRadius(of: demoLocation, radius: AppConstants.visibilityRadius)
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        checkVisibilityRadius()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            stopLocationUpdates()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
} 