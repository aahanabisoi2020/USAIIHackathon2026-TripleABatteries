import SwiftUI

// Dispatcher readout. Same situational info either way; framing line differs
// by role. Location block is live from LocationManager (street first, then
// 3-format coords / Plus Code fallback).
struct DispatcherView: View {
    @Binding var path: NavigationPath
    let assessment: Assessment
    let role: UserRole
    @ObservedObject var location: LocationManager

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Tell the dispatcher")
                    .font(.system(size: 21, weight: .semibold)).foregroundColor(AppColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Read this out when they answer.")
                    .font(.system(size: 14)).foregroundColor(AppColor.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 9)

                VStack(spacing: 5) {
                    if role == .victim {
                        InfoChip(icon: "person", text: refToSelf(assessment.situation))
                        InfoChip(icon: "clock", text: durationLine)
                    } else {
                        InfoChip(icon: "person", text: personLine)
                        InfoChip(icon: "clock", text: durationLine)
                    }
                    InfoChip(icon: "waveform.path.ecg", text: "Urgency: \(assessment.severity.rawValue)",
                             alarming: assessment.severity == .critical)
                }

                // Live location block
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.and.ellipse").font(.system(size: 11))
                        Text(location.street).font(.system(size: 14, weight: .medium))
                    }.foregroundColor(AppColor.ink)
                    locRow("Lat/long", location.latLngText)
                    locRow("Plus code", location.plusCode.isEmpty ? "—" : location.plusCode)
                }
                .padding(8)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.sm).stroke(AppColor.ink, lineWidth: 1.5))
                .padding(.top, 6)

                HStack {
                    Image(systemName: role == .victim ? "person.fill.questionmark" : "person.2")
                    Text(role == .victim ? "\"I need help.\""
                                         : "\"I'm a bystander — the person near me needs help.\"")
                    Spacer()
                }
                .font(.system(size: 12)).foregroundColor(.white)
                .padding(11)
                .background(role == .victim ? AppColor.danger : AppColor.ink)
                .cornerRadius(AppRadius.sm)
                .padding(.top, 8)

                Spacer()
                DangerButton(title: "Call emergency now") { /* TODO: place call */ }
            }
            .padding(.horizontal, 18).padding(.top, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) {
            Text("Soma").font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }}
    }

    private var personLine: String {
        let resp = assessment.responsive == "No" ? "unresponsive"
                 : assessment.responsive == "Yes" ? "responsive" : "response unknown"
        let who = assessment.person == "Not stated" ? "Person" : assessment.person
        return "\(who), \(resp)"
    }
    private var durationLine: String {
        assessment.duration == "Not stated" ? "Duration not stated" : "Lasting \(assessment.duration), ongoing"
    }
    private func refToSelf(_ s: String) -> String {
        "I think this is: \(s.lowercased())"
    }
    private func locRow(_ k: String, _ v: String) -> some View {
        HStack {
            Text(k).font(.system(size: 13)).foregroundColor(AppColor.secondary)
            Spacer()
            Text(v).font(.system(size: 13, design: .monospaced)).foregroundColor(AppColor.ink)
        }
    }
}
