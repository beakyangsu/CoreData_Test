//
//  ContentView.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import SwiftUI
import CoreData

struct SearchConfig: Equatable {
    enum Filter {
        case all
        case fave
    }
    var query: String = ""
    var filter: Filter = .all
}

enum Sort {
    case asc
    case desc
}

struct ContentView: View {
    //변화있으면 알아서 패치 새로해줌
    @FetchRequest(fetchRequest: Contact.all()) private var contacts
    @State private var contactToEdit: Contact? = nil
    @State private var searchConfig: SearchConfig = .init()
    @State private var sort: Sort = .asc
    //SearchConfig랑 섞이지않도록 분리해서 관리해야함

    var provider = ContactsProvider.shared

    var body: some View {
        NavigationStack {
            ZStack {
                if contacts.isEmpty {
                        NoContactsView()

                } else {
                    List {
                        ForEach(contacts) { item in
                            // NavigationLink 의 > 아이콘을 숨기는 방법
                            ZStack(alignment: .leading) {
                                NavigationLink {
                                    ContactDetailView(contact: item)
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                                ContactRowView(contact: item, provider: provider)
                                    .swipeActions(allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            do {
                                                //delete도 newContext로 해서 현재 흐름과 분리하는게 안전 

                                                try provider.delete(item, context: provider.newContext)
                                            } catch {
                                                print(error)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        .tint(.red)

                                        Button {
                                            contactToEdit = item
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(.orange)

                                    }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchConfig.query)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        //Context를 분리시켜야 엠티가 추가되지않음
                        contactToEdit = .empty(context:provider.newContext)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Section {
                            Text("Filter")
                            Picker(selection: $searchConfig.filter) {
                                Text("All").tag(SearchConfig.Filter.all)
                                Text("Favourites").tag(SearchConfig.Filter.fave)
                            } label: {
                                Text("Filter Faves")
                            }
                        }

                        Section {
                            Text("Sort")
                            Picker(selection: $sort) {
                                Label("Asc", systemImage: "arrow.up").tag(Sort.asc)
                                Label("Desc", systemImage: "arrow.down").tag(Sort.desc)
                            } label: {
                                Text("Sort By")
                            }
                        }

                    } label: {
                        Image(systemName: "ellipsis")
                            .symbolVariant(.circle)
                            .font(.title2)
                    }
                }
            }
            .sheet(item: $contactToEdit, onDismiss: {
                contactToEdit = nil
            }, content: { contact in
                NavigationStack {
                    CreateContactView(vm: .init(provider: provider, contact: contact))
                }
            })
            .navigationTitle("Contacts")
            .onChange(of: searchConfig) { newConfig in
                contacts.nsPredicate = Contact.filter(with: newConfig)
            }
            .onChange(of: sort) { newSort in
                contacts.nsSortDescriptors = Contact.sort(order: newSort)
            }

        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let preview = ContactsProvider.shared
        ContentView(provider: preview)
            .environment(\.managedObjectContext, preview.viewContext)
            .previewDisplayName("Contacts With Data")
            .onAppear { Contact.makePreview(count: 10,
                                            in: preview.viewContext) }
        
        let emptyPreview = ContactsProvider.shared
        ContentView(provider: emptyPreview)
            .environment(\.managedObjectContext, emptyPreview.viewContext)
            .previewDisplayName("Contacts With No Data")
    }
}

