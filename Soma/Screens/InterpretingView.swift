import SwiftUI

// Interprets the caller's text, then runs the confidence gate.
//   Primary brain : Gemini (LLMTriage) — real language understanding.
//   Fallback      : TriageEngine (offline rules) — if no key/network/parse.
// Both return the same Assessment, so the gate & all screens are unchanged.
struct InterpretingView: View {
    @Binding var path: NavigationPath
    let role: UserRole
    let text: String
    @State private var spin = false

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 16) {
                Spacer()
                ZStack {
                    Circle().fill(AppColor.midGray).frame(width: 84, height: 84)
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 36)).foregroundColor(AppColor.darkGray)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                        .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: spin)
                }
                Text("Understanding…")
                    .font(.system(size: 19, weight: .semibold)).foregroundColor(AppColor.ink)
                Text("Reading what you said and checking how urgent this is.")
                    .font(.system(size: 15)).foregroundColor(AppColor.secondary)
                    .multilineTextAlignment(.center).padding(.horizontal, 32)
                Spacer()
            }
            .padding(.horizontal, 18)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) {
            Text("Soma").font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }}
        .task {
            spin = true
            // Try the LLM first; fall back to the offline engine on any failure.
            let assessment = await LLMTriage.assess(text) ?? TriageEngine.assess(text)
            // Small floor so the spinner reads as "working" even if the call is instant.
            try? await Task.sleep(nanoseconds: 700_000_000)
            path.append(ConfidenceGate.route(for: assessment, role: role))
        }
    }
}
