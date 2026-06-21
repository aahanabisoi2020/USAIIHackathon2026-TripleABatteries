import SwiftUI

// MARK: - Design tokens
// Monochrome system. Red (danger) is reserved ONLY for SOS / call / urgent states.
enum AppColor {
    static let ink        = Color(red: 0.17,  green: 0.17,  blue: 0.16)  // #2C2C2A
    static let secondary  = Color(red: 0.37,  green: 0.37,  blue: 0.35)  // #5F5E5A
    static let muted      = Color(red: 0.53,  green: 0.53,  blue: 0.50)  // #888780
    static let fill       = Color(red: 0.945, green: 0.937, blue: 0.91)  // #F1EFE8
    static let border     = Color(red: 0.706, green: 0.698, blue: 0.663) // #B4B2A9
    static let hairline   = Color(red: 0.85,  green: 0.84,  blue: 0.80)
    static let midGray    = Color(red: 0.83,  green: 0.82,  blue: 0.78)  // #D3D1C7
    static let darkGray   = Color(red: 0.27,  green: 0.27,  blue: 0.25)  // #444441
    static let danger     = Color(red: 0.827, green: 0.184, blue: 0.184) // #D32F2F
    static let dangerDeep = Color(red: 0.314, green: 0.075, blue: 0.075) // #501313
    static let canvas     = Color.white
}

enum AppRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
}

// MARK: - Status bar row (time + app name)
struct StatusBar: View {
    var name: String = "Soma"
    var body: some View {
        HStack {
            Text("9:41").font(.system(size: 12)).foregroundColor(AppColor.muted)
            Spacer()
            Text(name).font(.system(size: 13, weight: .medium)).foregroundColor(AppColor.ink)
        }
    }
}

// MARK: - Always-available SOS button
struct SOSButton: View {
    var label: String = "SOS — Call now"
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 19, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(AppColor.danger)
                .cornerRadius(AppRadius.md)
        }
    }
}

// MARK: - Neutral primary (continue) button
struct PrimaryButton: View {
    let title: String
    var filled: Bool = true
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(filled ? .white : AppColor.ink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(filled ? AppColor.ink : Color.clear)
                .cornerRadius(AppRadius.md)
        }
    }
}

// MARK: - Red call/connect button (urgent action)
struct DangerButton: View {
    let title: String
    var systemIcon: String? = "phone.fill"
    var inverted: Bool = false
    var action: () -> Void = {}
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let systemIcon { Image(systemName: systemIcon) }
                Text(title)
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(inverted ? AppColor.danger : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(inverted ? Color.white : AppColor.danger)
            .cornerRadius(AppRadius.md)
        }
    }
}

// MARK: - A labelled info chip (light fill, used in summaries)
struct InfoChip: View {
    let icon: String
    let text: String
    var alarming: Bool = false
    var body: some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(alarming ? AppColor.danger : AppColor.secondary)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(alarming ? AppColor.danger : AppColor.ink)
            Spacer()
        }
        .padding(.vertical, 11).padding(.horizontal, 13)
        .background(AppColor.fill)
        .cornerRadius(AppRadius.sm)
    }
}

// MARK: - Key/value row used in the "what I understood" screen
struct DetailRow: View {
    let key: String
    let value: String
    var alarming: Bool = false
    var body: some View {
        HStack {
            Text(key).font(.system(size: 15)).foregroundColor(AppColor.secondary)
            Spacer()
            Text(value).font(.system(size: 15, weight: .medium))
                .foregroundColor(alarming ? AppColor.danger : AppColor.ink)
        }
        .padding(.vertical, 13).padding(.horizontal, 14)
        .background(AppColor.fill)
        .cornerRadius(AppRadius.sm)
    }
}
