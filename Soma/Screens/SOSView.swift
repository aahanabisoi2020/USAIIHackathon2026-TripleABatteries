import SwiftUI
import Combine
internal import _LocationEssentials

// SOS emergency screen — StrokeSense-style.
// Big TAP TO CALL, "My Location / Tell the operator your…" card with
// street, lat/long, and what3words, plus Cancel SOS. Dials the correct
// local number resolved from the user's country.
struct SOSView: View {
    @Binding var path: NavigationPath
    @ObservedObject var location: LocationManager
    @StateObject private var numbers = EmergencyNumbers()
    @StateObject private var w3w = What3Words()

    var body: some View {
        ZStack {
            AppColor.danger.ignoresSafeArea()
            VStack(spacing: 0) {

                Text("EMERGENCY")
                    .font(.system(size: 46, weight: .heavy))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                // TAP TO CALL
                Button { call() } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "phone.fill").font(.system(size: 26, weight: .bold))
                        Text("TAP TO CALL").font(.system(size: 30, weight: .heavy))
                    }
                    .foregroundColor(AppColor.danger)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
                    .background(Color.white)
                    .cornerRadius(22)
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)

                Spacer()

                // Location card
                VStack(spacing: 0) {
                    Text("My Location")
                        .font(.system(size: 26, weight: .bold)).foregroundColor(.black)
                        .padding(.top, 22)
                    Text("Tell the operator your…")
                        .font(.system(size: 17)).foregroundColor(.gray)
                        .padding(.top, 2).padding(.bottom, 16)

                    Divider().padding(.horizontal, 24)

                    Text(streetPrimary)
                        .font(.system(size: 28, weight: .bold)).foregroundColor(.black)
                        .padding(.top, 18)
                    Text(streetSecondary)
                        .font(.system(size: 18)).foregroundColor(.gray)
                        .padding(.top, 2)

                    HStack(spacing: 50) {
                        VStack(spacing: 2) {
                            Text("Latitude").font(.system(size: 15)).foregroundColor(.gray)
                            Text(latText).font(.system(size: 22, weight: .bold)).foregroundColor(AppColor.danger)
                        }
                        VStack(spacing: 2) {
                            Text("Longitude").font(.system(size: 15)).foregroundColor(.gray)
                            Text(lngText).font(.system(size: 22, weight: .bold)).foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 18)

                    VStack(spacing: 2) {
                        Text("what3words").font(.system(size: 15)).foregroundColor(.gray)
                        Text(w3wDisplay).font(.system(size: 24, weight: .bold)).foregroundColor(.black)
                    }
                    .padding(.top, 16).padding(.bottom, 24)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(28)
                .padding(.horizontal, 18)

                Spacer()

                // Cancel
                Button { path.removeLast() } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "xmark").font(.system(size: 18, weight: .semibold))
                        Text("Cancel SOS").font(.system(size: 20, weight: .medium))
                    }.foregroundColor(.white)
                }
                .padding(.bottom, 28)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            numbers.resolve(for: location.coordinate)
            w3w.resolve(for: location.coordinate)
        }
        .onChange(of: location.coordinate?.latitude) { _ in
            numbers.resolve(for: location.coordinate)
            w3w.resolve(for: location.coordinate)
        }
    }

    // Split street into primary / secondary lines like the StrokeSense card.
    private var streetPrimary: String {
        location.street.components(separatedBy: ", ").first ?? location.street
    }
    private var streetSecondary: String {
        let parts = location.street.components(separatedBy: ", ")
        return parts.count > 1 ? parts.dropFirst().joined(separator: ", ") : ""
    }
    private var latText: String { location.coordinate.map { String(format: "%.4f°", $0.latitude) } ?? "—" }
    private var lngText: String { location.coordinate.map { String(format: "%.4f°", $0.longitude) } ?? "—" }
    private var w3wDisplay: String { w3w.words.isEmpty ? "///\(location.plusCode)" : "///\(w3w.words)" }

    private func call() {
        let n = numbers.number.filter { $0.isNumber }
        if let url = URL(string: "tel://\(n)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
