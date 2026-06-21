import SwiftUI

// Sourced first-aid card (Version B). Content is SELECTED from the vetted,
// attributed Rulebook — the AI did not author it. Shows: when to call,
// scannable steps, key "do NOT" safety notes, the source, a disclaimer,
// and an always-visible connect-to-help button.
struct StepsView: View {
    @Binding var path: NavigationPath
    let assessment: Assessment
    let role: UserRole

    private var guide: AidGuide { Rulebook.guide(for: assessment.kind) }

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {

                        Text("While you wait for help")
                            .font(.system(size: 15)).foregroundColor(AppColor.secondary)
                        Text(guide.title)
                            .font(.system(size: 23, weight: .bold)).foregroundColor(AppColor.ink)

                        // When to call (red, high priority)
                        HStack(alignment: .top, spacing: 7) {
                            Image(systemName: "phone.fill").font(.system(size: 11)).foregroundColor(.white)
                            Text(guide.whenToCall).font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                        }
                        .padding(10).frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColor.danger).cornerRadius(AppRadius.sm)

                        // Steps
                        ForEach(Array(guide.shortSteps.enumerated()), id: \.offset) { i, step in
                            HStack(alignment: .top, spacing: 11) {
                                Text("\(i + 1)")
                                    .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                    .frame(width: 30, height: 30).background(AppColor.ink).clipShape(Circle())
                                Text(step).font(.system(size: 16)).foregroundColor(AppColor.ink)
                                Spacer()
                            }
                            .padding(10).background(AppColor.fill).cornerRadius(AppRadius.sm)
                        }

                        // Do NOT notes (key safety content)
                        if !guide.avoid.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                ForEach(guide.avoid, id: \.self) { note in
                                    HStack(alignment: .top, spacing: 7) {
                                        Image(systemName: "xmark.circle").font(.system(size: 11))
                                            .foregroundColor(AppColor.danger)
                                        Text(note).font(.system(size: 15)).foregroundColor(AppColor.ink)
                                    }
                                }
                            }
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: AppRadius.sm)
                                .stroke(AppColor.danger, lineWidth: 1))
                        }

                        // Attribution + disclaimer (defensibility)
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.seal").font(.system(size: 11))
                            Text("Source: \(guide.source)").font(.system(size: 13))
                        }.foregroundColor(AppColor.secondary)
                        Text("General first-aid guidance, not a diagnosis. Follow the dispatcher's instructions.")
                            .font(.system(size: 13)).foregroundColor(AppColor.muted)
                    }
                    .padding(.bottom, 12)
                }

                DangerButton(title: "Connect to emergency help") {
                    path.append(Route.dispatcher(assessment: assessment, role: role))
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
