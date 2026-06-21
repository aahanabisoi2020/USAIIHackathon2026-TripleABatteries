import Foundation
import CoreLocation
import Combine

// =====================================================================
// Soma — Emergency number lookup (emergencynumberapi.com)
//   • No API key required (rate-limited 5 req/s).
//   • Resolves the caller's ISO country from their coordinate, then
//     fetches the correct local dispatch/ambulance number.
//   • Falls back to 112 (works across EU + many GSM networks) then 911.
// =====================================================================

@MainActor
final class EmergencyNumbers: ObservableObject {
    @Published var number: String = "112"   // safe default until resolved

    private let geocoder = CLGeocoder()

    func resolve(for coordinate: CLLocationCoordinate2D?) {
        guard let c = coordinate else { return }
        geocoder.reverseGeocodeLocation(CLLocation(latitude: c.latitude, longitude: c.longitude)) { [weak self] places, _ in
            guard let iso = places?.first?.isoCountryCode else { return }
            Task { await self?.fetch(iso) }
        }
    }

    private func fetch(_ iso: String) async {
        guard let url = URL(string: "https://emergencynumberapi.com/api/country/\(iso)") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let top = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let d = top["data"] as? [String: Any] else { return }
            // Prefer a single dispatch number; else ambulance; else 112/911.
            let picked = firstNumber(d["Dispatch"]) ?? firstNumber(d["Ambulance"]) ?? firstNumber(d["Police"])
            let member112 = (d["Member_112"] as? Bool) ?? false
            if let picked { self.number = picked }
            else if member112 { self.number = "112" }
            else { self.number = "911" }
        } catch {
            // keep default
        }
    }

    // Each service has an "All" array (strings); grab the first usable number.
    private func firstNumber(_ service: Any?) -> String? {
        guard let s = service as? [String: Any] else { return nil }
        if let all = s["All"] as? [String], let n = all.first, !n.isEmpty { return n }
        if let gsm = s["GSM"] as? [String], let n = gsm.first, !n.isEmpty { return n }
        return nil
    }
}
