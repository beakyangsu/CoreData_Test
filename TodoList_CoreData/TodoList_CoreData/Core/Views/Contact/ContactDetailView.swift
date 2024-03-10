//
//  ContactDetailView.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import SwiftUI

//navigation link로 넘어올거니까 NavigationStack울 여기에 넣으면안됨
struct ContactDetailView: View {
    let contact: Contact
    var body: some View {
            List {
                Section("General") {
                    LabeledContent {
                        Text(contact.email)
                    } label: {
                        Text("Email")
                    }

                    LabeledContent {
                        Text(contact.phoneNumber)
                    } label: {
                        Text("Phone Number")
                    }

                    LabeledContent {
                        Text(contact.dob, style: .date)
                    } label: {
                        Text("Birthday")
                    }
                }

                Section("Notes") {
                    Text(contact.notes)
                }
            }
            .navigationTitle(contact.formattedName)

    }
}

#Preview {
    NavigationStack {
        ContactDetailView(contact: .preview())
    }
}
