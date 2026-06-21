import SwiftUI

struct HomeDashboardView: View {
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            VStack(spacing: 0) {

                // Top bar: time + settings gear
                HStack {
                    Text("9:41").font(.system(size: 12)).foregroundColor(AppColor.muted)
                    Spacer()
                    Button { path.append(Route.settings) } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 22)).foregroundColor(AppColor.ink)
                    }.accessibilityLabel("Settings")
                }
                .padding(.bottom, 22)

                Text("Soma")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(AppColor.ink)
                Text("Who needs help?")
                    .font(.system(size: 16)).foregroundColor(AppColor.secondary)
                    .padding(.bottom, 32)

                VStack(spacing: 16) {
                    ChoiceCard(icon: "person.2", title: "Someone near me",
                               subtitle: "I'm a bystander") {
                        path.append(Route.describe(role: .bystander))
                    }
                    ChoiceCard(icon: "person.fill.questionmark", title: "It's happening to me",
                               subtitle: "I need help myself") {
                        path.append(Route.describe(role: .victim))
                    }
                }

                Spacer()
                SOSButton { /* TODO: section 6 — trigger emergency call + location */ }
            }
            .padding(.horizontal, 18)
            .padding(.top, 10)
        }
        .navigationBarHidden(true)
    }
}

struct ChoiceCard: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon).font(.system(size: 34)).foregroundColor(AppColor.ink)
                Text(title).font(.system(size: 21, weight: .semibold)).foregroundColor(AppColor.ink)
                Text(subtitle).font(.system(size: 14)).foregroundColor(AppColor.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .overlay(RoundedRectangle(cornerRadius: AppRadius.lg)
                .stroke(AppColor.ink, lineWidth: 1.5))
        }
    }
}
