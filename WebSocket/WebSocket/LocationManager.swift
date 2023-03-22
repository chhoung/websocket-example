//
//  LocationManager.swift
//

import Foundation
import CoreLocation

final class LocationManager: NSObject {
    var didUpdateLocation: ((CLLocation) -> Void)?
    var locationAccessStatus: ((LocationAccessStatus) -> Void)?
    var lastTimeStamp: Date?
    var normalLocationTimeStamp: Date?
    var type: LocationRequestType = .normal
    var webSocketManager = WebSocketManager()
    
    private let locationManager = CLLocationManager()
    
    func requestLocation() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManager()
            
            let authorizationStatus = CLLocationManager.authorizationStatus()
            updateLocationAccessStatus(authorizationStatus)
            checkLocationAuthorization(authorizationStatus)
        }
        else {
            // Location service is entirely disabled
            locationAccessStatus?(.disabled)
        }
    }
    
    //always authorized location request
    func requestBackgroundLocation() {
        if CLLocationManager.locationServicesEnabled() {
            setUpLocationManagerDriver()
            webSocketManager.initiateConnection()
            
            let authorizationStatus = CLLocationManager.authorizationStatus()
            updateLocationAccessStatus(authorizationStatus)
            checkForAlwaysAuthorization(authorizationStatus)
        }
        else {
            // Location service is entirely disabled
            locationAccessStatus?(.disabled)
        }
    }
    
    func stopUpdatingLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
            
            webSocketManager.close()
        }
    }
    
    private func setUpLocationManagerDriver() {
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = .automotiveNavigation
    }
    
    private func setUpLocationManager() {
        locationManager.delegate = self
        locationManager.distanceFilter = 10
        locationManager.pausesLocationUpdatesAutomatically = true
    }
    
    private func checkForAlwaysAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined, .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    private func checkLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    private func updateLocationAccessStatus(_ authorizationStatus: CLAuthorizationStatus) {
        switch authorizationStatus {
        case .notDetermined:
            locationAccessStatus?(.notDetermined)
        case .authorizedWhenInUse, .authorizedAlways:
            locationAccessStatus?(.authorized)
        default:
            locationAccessStatus?(.unauthorized)
        }
    }
}


extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Location authorization status: \(status.description)")
        updateLocationAccessStatus(status)
        guard status == .authorizedWhenInUse else { return }
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("driver location did update: \(location)")

        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            webSocketManager.send(location: location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}


// MARK: -
private extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .restricted: return "restricted"
        case .denied: return "denied"
        case .authorizedAlways: return "authorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        @unknown default: return "unknown"
        }
    }
}


// MARK: -
enum LocationAccessStatus {
    case disabled, notDetermined, authorized, unauthorized
}

// MARK: -
enum LocationRequestType {
    case background, normal
}
