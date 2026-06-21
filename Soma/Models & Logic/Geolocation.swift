import Foundation
import CoreLocation
import Combine

// MARK: - Plus Code (Google)
enum PlusCode {
    private static let alphabet = Array("23456789CFGHJMPQRVWX")
    private static let res: [Double] = [20, 1, 0.05, 0.0025, 0.000125]

    static func encode(_ latitude: Double, _ longitude: Double) -> String {
        var lat = min(90, max(-90, latitude))
        var lng = longitude.truncatingRemainder(dividingBy: 360)
        if lng < 0 { lng += 360 }
        if lng >= 180 { lng -= 360 }
        if lat >= 90 { lat = 89.9999999 }
        var a = lat + 90, o = lng + 180
        var code = ""
        for i in 0..<5 {
            let r = res[i]
            var ld = Int((a / r).rounded(.down)); a -= Double(ld) * r
            var gd = Int((o / r).rounded(.down)); o -= Double(gd) * r
            ld = min(19, max(0, ld)); gd = min(19, max(0, gd))
            code.append(alphabet[ld]); code.append(alphabet[gd])
            if code.count == 8 { code.append("+") }
        }
        return code
    }
}

// MARK: - Location manager
@MainActor
final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var street: String = "Locating…"
    @Published var coordinate: CLLocationCoordinate2D?
    @Published var accuracy: Double = 0
    @Published var plusCode: String = ""

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    var latLngText: String {
        guard let c = coordinate else { return "—" }
        return String(format: "%.5f, %.5f", c.latitude, c.longitude)
    }

    nonisolated func locationManager(_ m: CLLocationManager, didUpdateLocations locs: [CLLocation]) {
        guard let loc = locs.last else { return }
        Task { @MainActor in
            self.coordinate = loc.coordinate
            self.accuracy = loc.horizontalAccuracy
            self.plusCode = PlusCode.encode(loc.coordinate.latitude, loc.coordinate.longitude)
            // Reverse geocode for a human street name; Plus Code remains the fallback.
            self.geocoder.reverseGeocodeLocation(loc) { places, _ in
                if let p = places?.first {
                    let parts = [p.thoroughfare, p.subLocality ?? p.locality].compactMap { $0 }
                    self.street = parts.isEmpty ? "Near Plus Code \(self.plusCode)" : parts.joined(separator: ", ")
                }
            }
        }
    }

    nonisolated func locationManager(_ m: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in self.street = self.plusCode.isEmpty ? "Location unavailable" : "Near \(self.plusCode)" }
    }
}
