import SwiftUI

// Low-confidence path: the engine isn't sure, so it SKIPS guidance and
// connects straight to a human — the human-in-the-loop safeguard, visible.
// Location is still surfaced so the dispatcher gets it immediately.
struct UncertainView: View {
    @Binding var path: NavigationPath
    let assessment: Assessment
    @ObservedObject var location: LocationManager

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                Spacer()
                ZStack {
                    Circle().fill(AppColor.fill).frame(width: 76, height: 76)
                    Circle().stroke(AppColor.danger, lineWidth: 2).frame(width: 76, height: 76)
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 34)).foregroundColor(AppColor.danger)
                }
                Text("I'm not certain what this is.")
                    .font(.system(size: 19, weight: .semibold)).foregroundColor(AppColor.ink)
                    .padding(.top, 14)
                Text("Connecting you directly to emergency services now — they'll take it from here.")
                    .font(.system(size: 15)).foregroundColor(AppColor.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 28).padding(.top, 4)

                // Still hand the human your location.
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.and.ellipse").font(.system(size: 11))
                        Text(location.street).font(.system(size: 11, weight: .medium))
                    }.foregroundColor(AppColor.ink)
                    HStack {
                        Text("Plus code").font(.system(size: 10)).foregroundColor(AppColor.secondary)
                        Spacer()
                        Text(location.plusCode.isEmpty ? "—" : location.plusCode)
                            .font(.system(size: 10, design: .monospaced)).foregroundColor(AppColor.ink)
                    }
                }
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.sm).stroke(AppColor.border, lineWidth: 1))
                .padding(.top, 16)

                Spacer()
                DangerButton(title: "Connecting to 999…") { /* TODO: place call */ }
            }
            .padding(.horizontal, 18).padding(.top, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) {
            Text("Soma").font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }}
    }
}
