import SwiftUI

struct DescribeView: View {
    @Binding var path: NavigationPath
    let role: UserRole
    @State private var text: String = ""
    @StateObject private var speech = SpeechDictation()

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("What's happening?")
                        .font(.system(size: 22, weight: .semibold)).foregroundColor(AppColor.ink)
                    Text(role == .victim ? "Describe what's happening to you."
                                         : "Say or type what you're seeing.")
                        .font(.system(size: 15)).foregroundColor(AppColor.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 14)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: AppRadius.sm).fill(AppColor.fill)
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(AppColor.border, lineWidth: 1))
                    if displayText.isEmpty {
                        Text("\"she fell and she's shaking and won't respond\"")
                            .font(.system(size: 16)).foregroundColor(AppColor.secondary).padding(14)
                    }
                    TextEditor(text: Binding(
                        get: { displayText },
                        set: { text = $0 }
                    ))
                    .font(.system(size: 16)).foregroundColor(AppColor.ink)
                    .scrollContentBackground(.hidden).padding(8)
                }
                .frame(height: 120)

                VStack(spacing: 6) {
                    Button {
                        speech.toggle()
                    } label: {
                        Image(systemName: speech.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 32)).foregroundColor(.white)
                            .frame(width: 82, height: 82)
                            .background(speech.isRecording ? AppColor.danger : AppColor.ink)
                            .clipShape(Circle())
                    }
                    Text(speech.isRecording ? "Listening… tap to stop" : "Tap to speak")
                        .font(.system(size: 14)).foregroundColor(AppColor.secondary)
                }
                .padding(.top, 22)

                Spacer()

                PrimaryButton(title: "Continue") {
                    if speech.isRecording { speech.stop() }
                    path.append(Route.interpreting(role: role, text: displayText))
                }
                .opacity(displayText.isEmpty ? 0.4 : 1).disabled(displayText.isEmpty)
                .padding(.bottom, 8)

                SOSButton { path.append(Route.sos) }
            }
            .padding(.horizontal, 18).padding(.top, 10)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { ToolbarItem(placement: .principal) {
            Text("Soma").font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }}
    }

    // Show the live transcript while recording, otherwise the typed text.
    private var displayText: String {
        speech.isRecording && !speech.transcript.isEmpty ? speech.transcript
            : (text.isEmpty ? speech.transcript : text)
    }
}
