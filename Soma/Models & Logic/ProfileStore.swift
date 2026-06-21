import Foundation
import SwiftUI
import Combine
// =====================================================================
// Soma — on-device profile storage (section 7)
//   • Saved locally with UserDefaults (a simple on-device store).
//   • NOTHING is uploaded — this is the privacy guarantee.
//   • `eraseAll()` wipes every field. (For real medical data you'd use
//     the Keychain; UserDefaults is fine for the hackathon demo.)
// =====================================================================

@MainActor
final class ProfileStore: ObservableObject {
    @Published var preferredName = ""  { didSet { save() } }
    @Published var legalName = ""      { didSet { save() } }
    @Published var age = ""            { didSet { save() } }
    @Published var gender = ""         { didSet { save() } }
    @Published var medicalInfo = ""    { didSet { save() } }
    @Published var medicalHistory = "" { didSet { save() } }
    @Published var contacts: [String] = [] { didSet { save() } }

    private let key = "soma.profile.v1"
    private var loading = false

    init() { load() }

    private func save() {
        guard !loading else { return }   // don't re-save while loading
        let dict: [String: Any] = [
            "preferredName": preferredName, "legalName": legalName,
            "age": age, "gender": gender, "medicalInfo": medicalInfo,
            "medicalHistory": medicalHistory, "contacts": contacts
        ]
        UserDefaults.standard.set(dict, forKey: key)
    }

    private func load() {
        loading = true
        defer { loading = false }
        guard let d = UserDefaults.standard.dictionary(forKey: key) else { return }
        preferredName  = d["preferredName"] as? String ?? ""
        legalName      = d["legalName"] as? String ?? ""
        age            = d["age"] as? String ?? ""
        gender         = d["gender"] as? String ?? ""
        medicalInfo    = d["medicalInfo"] as? String ?? ""
        medicalHistory = d["medicalHistory"] as? String ?? ""
        contacts       = d["contacts"] as? [String] ?? []
    }

    func eraseAll() {
        loading = true
        preferredName = ""; legalName = ""; age = ""; gender = ""
        medicalInfo = ""; medicalHistory = ""; contacts = []
        loading = false
        UserDefaults.standard.removeObject(forKey: key)
    }
}
