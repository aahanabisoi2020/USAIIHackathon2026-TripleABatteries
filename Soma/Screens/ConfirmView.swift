import SwiftUI

// "Here's what I understood" — the AI's structured reading + a short "why"
// (transparency). Continues to the sourced first-aid steps card.
struct ConfirmView: View {
    @Binding var path: NavigationPath
    let assessment: Assessment
    let role: UserRole

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Here's what I understood")
                    .font(.system(size: 21, weight: .semibold)).foregroundColor(AppColor.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)

                VStack(spacing: 7) {
                    DetailRow(key: "Situation", value: assessment.situation)
                    DetailRow(key: "Urgency", value: assessment.severity.rawValue,
                              alarming: assessment.severity == .critical)
                    DetailRow(key: "Person", value: assessment.person,
                              alarming: false)
                    DetailRow(key: "Duration", value: assessment.duration)
                    DetailRow(key: "Responsive", value: assessment.responsive,
                              alarming: assessment.responsive == "No")
                }

                // Transparency: why the system read it this way + confidence
                if !assessment.reasoning.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "info.circle").font(.system(size: 11))
                            .foregroundColor(AppColor.secondary)
                        Text("\(assessment.reasoning)  (confidence \(assessment.confidencePercent)%)")
                            .font(.system(size: 14)).foregroundColor(AppColor.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 9)
                }

                Text("Tap any item to correct it.")
                    .font(.system(size: 13)).foregroundColor(AppColor.muted)
                    .frame(maxWidth: .infinity, alignment: .leading).padding(.top, 4)

                Spacer()
                PrimaryButton(title: "Continue") {
                    path.append(Route.steps(assessment: assessment, role: role))
                }
            }
            .padding(.horizontal, 18).padding(.top, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) {
            Text("Soma").font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }}
    }
}
