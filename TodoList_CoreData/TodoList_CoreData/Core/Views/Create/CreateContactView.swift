//
//  CreateContactView.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import SwiftUI

struct CreateContactView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm : EditContactViewModel
    @State private var hasError: Bool = false

    var body: some View {
        List {
            Section("General") {
                TextField("Name", text: $vm.contact.name)
                    .keyboardType(.namePhonePad)

                TextField("Email", text: $vm.contact.email)
                    .keyboardType(.emailAddress)

                TextField("Phone Number", text: $vm.contact.phoneNumber)
                    .keyboardType(.phonePad)

                DatePicker("BirthDay", selection: $vm.contact.dob, displayedComponents: [.date])
                    .datePickerStyle(.compact)


                Toggle("Favourite", isOn: $vm.contact.isFavourite)

            }

            Section("Notes") {
                TextField("", text: $vm.contact.notes, axis: .vertical)
                //vertical을 해야 안잘리고 아래로 붙음
            }
        }
        .navigationTitle(vm.isNew ? "NEW Conatact" : "Update Contact")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    validate()
                }
            }

            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .alert("Someting ain't right",
               isPresented: $hasError, actions: {}) {
            Text("It looks like your form is invalid")
        }
    }
}

private extension CreateContactView {
    func validate() {
        if vm.contact.isValid {
            do {
                try vm.save()
                dismiss()
            } catch {
                print(error)
            }

        } else {
            hasError = true

        }
    }
}

#Preview {
    NavigationStack {
        let preview = ContactsProvider.shared
        CreateContactView(vm: .init(provider: preview))
            .environment(\.managedObjectContext, preview.viewContext)
    }
}
