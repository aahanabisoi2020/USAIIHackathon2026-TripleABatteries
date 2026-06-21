import SwiftUI
import Combine

// MARK: - App entry
@main
struct SomaApp: App {
    var body: some Scene {
        WindowGroup { RootView() }
    }
}

// MARK: - Who is using the app
enum UserRole: Hashable { case bystander, victim }

// (Assessment, Severity, AidKind now live in TriageEngine.swift)

// MARK: - Navigation routes
enum Route: Hashable {
    case describe(role: UserRole)
    case interpreting(role: UserRole, text: String)
    case confirm(assessment: Assessment, role: UserRole)
    case steps(assessment: Assessment, role: UserRole)     // sourced first-aid card (Version B)
    case dispatcher(assessment: Assessment, role: UserRole)
    case uncertain(assessment: Assessment)
    case settings
    case sos
}

// MARK: - Confidence gate (section 4)
// The single place that decides the route after interpretation.
// High confidence -> show sourced steps + dispatcher path.
// Low confidence  -> skip guidance, escalate straight to a human.
enum ConfidenceGate {
    static let threshold = 0.6
    static func route(for a: Assessment, role: UserRole) -> Route {
        a.confidence >= threshold
            ? .confirm(assessment: a, role: role)
            : .uncertain(assessment: a)
    }
}

// MARK: - Navigation shell
struct RootView: View {
    @State private var path = NavigationPath()
    @StateObject private var location = LocationManager()
    @StateObject private var profile = ProfileStore()

    var body: some View {
        NavigationStack(path: $path) {
            HomeDashboardView(path: $path)
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .describe(let role):
                        DescribeView(path: $path, role: role)
                    case .interpreting(let role, let text):
                        InterpretingView(path: $path, role: role, text: text)
                    case .confirm(let a, let role):
                        ConfirmView(path: $path, assessment: a, role: role)
                    case .steps(let a, let role):
                        StepsView(path: $path, assessment: a, role: role)
                    case .dispatcher(let a, let role):
                        DispatcherView(path: $path, assessment: a, role: role, location: location)
                    case .uncertain(let a):
                        UncertainView(path: $path, assessment: a, location: location)
                    case .settings:
                        SettingsView()
                    case .sos:
                        SOSView(path: $path, location: location)
                    }
                }
        }
        .tint(AppColor.ink)
        .environmentObject(location)
        .environmentObject(profile)
        .onAppear { location.start() }
    }
}
