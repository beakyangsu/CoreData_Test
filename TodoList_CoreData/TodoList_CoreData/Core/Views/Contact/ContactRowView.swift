//
//  ContactRowView.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import SwiftUI

struct ContactRowView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var contact: Contact

    let provider: ContactsProvider
    var body: some View {

        VStack(alignment: .leading, spacing: 8) {
            Text(contact.formattedName)
                .font(.system(size:26, design: .rounded).bold())
            Text(contact.email)
                .font(.callout.bold())
            Text(contact.phoneNumber)
                .font(.callout.bold())
        }
        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
        .overlay(alignment: .topTrailing) {
            Button {
                // TODO:
                contact.toggleFave(provider: provider)

            } label: {
                 Image(systemName: "star")
                    .font(.title3)
                    .symbolVariant(.fill)
                    .foregroundStyle(contact.isFavourite ? .yellow : .gray.opacity(0.3))
            }
            .buttonStyle(.plain)
        }
    }
}


struct ContactRowView_Previews: PreviewProvider {
    static var previews: some View {
        let previewProvider = ContactsProvider.shared
        ContactRowView(contact: .preview(context: previewProvider.viewContext),
                       provider: previewProvider)
    }
}
//
//#Preview {
//    let provider = ContactsProvider.shared
//    ContactRowView(contact: Contact.preview(context: provider.viewContext), provider: provider)
//        .environment(\.managedObjectContext, provider.viewContext)
//}
