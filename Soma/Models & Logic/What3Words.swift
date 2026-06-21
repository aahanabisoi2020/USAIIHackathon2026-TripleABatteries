import Foundation
import CoreLocation
import Combine

// =====================================================================
// Soma — what3words lookup
//   Converts a coordinate to a 3-word address.
//   >>> PUT YOUR what3words API KEY in `apiKey` below. <<<
//   Until a key is set, returns nil and the UI shows the Plus Code instead.
// =====================================================================

@MainActor
final class What3Words: ObservableObject {
    @Published var words: String = ""        // e.g. "debt.apple.flux"

    // ───────────────────────────────────────────────
    private let apiKey = "BINA6NRB"
    // ───────────────────────────────────────────────

    func resolve(for coordinate: CLLocationCoordinate2D?) {
        guard apiKey != "BINA6NRB", let c = coordinate else { return }
        let urlStr = "https://api.what3words.com/v3/convert-to-3wa?coordinates=\(c.latitude),\(c.longitude)&key=\(apiKey)"
        guard let url = URL(string: urlStr) else { return }
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let top = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let w = top["words"] as? String {
                    self.words = w
                }
            } catch { /* leave empty -> UI falls back to Plus Code */ }
        }
    }
}
