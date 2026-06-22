import Foundation

enum Secrets {
    private static let store: [String: Any] = {
        guard let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let dict = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any]
        else { return [:] }
        return dict
    }()
    static var geminiAPIKey: String {
        (store["GeminiAPIKey"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }
    static var hasGeminiKey: Bool { !geminiAPIKey.isEmpty }
}
