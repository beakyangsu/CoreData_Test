//
//  TodoList_CoreDataApp.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import SwiftUI

@main
struct TodoList_CoreDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.managedObjectContext, ContactsProvider.shared.viewContext)
            //ContentView()
        }
    }
}
