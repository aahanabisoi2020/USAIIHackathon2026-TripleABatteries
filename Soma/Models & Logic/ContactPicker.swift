import SwiftUI
import ContactsUI

// =====================================================================
// Soma — system contact picker (real iOS Contacts UI)
//   Presents the native picker; returns "Name · +number".
// =====================================================================

struct ContactPicker: UIViewControllerRepresentable {
    var onPick: (String) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let p = CNContactPickerViewController()
        p.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        p.delegate = context.coordinator
        return p
    }
    func updateUIViewController(_ c: CNContactPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(onPick: onPick) }

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let onPick: (String) -> Void
        init(onPick: @escaping (String) -> Void) { self.onPick = onPick }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            let number = contact.phoneNumbers.first?.value.stringValue ?? ""
            onPick(number.isEmpty ? name : "\(name) · \(number)")
        }
    }
}
