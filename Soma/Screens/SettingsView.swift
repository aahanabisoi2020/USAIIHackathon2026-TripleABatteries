import SwiftUI

// Profile / settings — persists on-device via ProfileStore. Contacts use the
// native picker. "Erase all data" wipes everything (real privacy guarantee).
struct SettingsView: View {
    @EnvironmentObject var profile: ProfileStore
    @State private var showPicker = false
    @State private var confirmErase = false

    var body: some View {
        ZStack {
            AppColor.canvas.ignoresSafeArea()
            ScrollView {
                VStack(spacing: 20) {
                    field("Preferred name", "Enter preferred name", $profile.preferredName)
                    field("Legal name", "Enter legal name", $profile.legalName)
                    HStack(spacing: 10) {
                        field("Age", "Age", $profile.age)
                        field("Gender", "Gender", $profile.gender)
                    }
                    field("Medical info", "Conditions, meds, allergies", $profile.medicalInfo)
                    field("Medical history", "Past diagnoses, events", $profile.medicalHistory)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("EMERGENCY CONTACTS")
                            .font(.system(size: 12, weight: .medium)).foregroundColor(AppColor.secondary).kerning(0.4)
                        ForEach(profile.contacts, id: \.self) { c in
                            HStack {
                                Image(systemName: "person.crop.circle").foregroundColor(AppColor.secondary)
                                Text(c).font(.system(size: 15)).foregroundColor(AppColor.ink)
                                Spacer()
                                Button { profile.contacts.removeAll { $0 == c } } label: {
                                    Image(systemName: "xmark.circle.fill").foregroundColor(AppColor.border)
                                }
                            }
                            .padding(.vertical, 11).padding(.horizontal, 13)
                            .background(AppColor.fill).cornerRadius(AppRadius.sm)
                        }
                        Button { showPicker = true } label: {
                            HStack {
                                Image(systemName: "plus.circle")
                                Text("Add contact").font(.system(size: 15, weight: .medium))
                                Spacer()
                            }
                            .foregroundColor(AppColor.ink)
                            .padding(.vertical, 13).padding(.horizontal, 13)
                            .overlay(RoundedRectangle(cornerRadius: AppRadius.sm)
                                .stroke(AppColor.border, lineWidth: 1))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Button { confirmErase = true } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash"); Text("Erase all data")
                        }
                        .font(.system(size: 16, weight: .medium)).foregroundColor(AppColor.danger)
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .overlay(RoundedRectangle(cornerRadius: AppRadius.md)
                            .stroke(AppColor.danger, lineWidth: 1.5))
                    }
                    .padding(.top, 6)

                    HStack(spacing: 5) {
                        Image(systemName: "lock").font(.system(size: 13))
                        Text("Stored on this device only · never uploaded").font(.system(size: 13))
                    }
                    .foregroundColor(AppColor.secondary).padding(.top, 2)
                }
                .padding(.horizontal, 18).padding(.vertical, 12)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPicker) {
            ContactPicker { picked in profile.contacts.append(picked) }
        }
        .alert("Erase all data?", isPresented: $confirmErase) {
            Button("Cancel", role: .cancel) {}
            Button("Erase", role: .destructive) { profile.eraseAll() }
        } message: {
            Text("This permanently removes everything stored on this device. It cannot be undone.")
        }
    }

    private func field(_ label: String, _ placeholder: String, _ binding: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 12, weight: .medium)).foregroundColor(AppColor.secondary).kerning(0.4)
            TextField(placeholder, text: binding)
                .font(.system(size: 16)).foregroundColor(AppColor.ink)
                .padding(.vertical, 15).padding(.horizontal, 14)
                .overlay(RoundedRectangle(cornerRadius: AppRadius.sm)
                    .stroke(AppColor.border, lineWidth: 1))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
