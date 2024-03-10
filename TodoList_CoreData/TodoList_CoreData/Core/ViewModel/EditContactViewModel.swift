//
//  EditContactViewModel.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import Foundation
import CoreData

final class EditContactViewModel: ObservableObject {
    @Published var contact: Contact

    let isNew: Bool
    private let context: NSManagedObjectContext
    private let provider: ContactsProvider

    init(provider: ContactsProvider, contact: Contact? = nil) {
        //수정하는거라 newContext인건가
        //수정의 저장이 지금에 VIewcontext에 영향주지않도록?
        self.context = provider.newContext
        self.provider = provider

        if let contact, let exsistingCopy = provider.exsists(contact, context: context) {
            self.contact = exsistingCopy
            self.isNew = false
        } else {
            self.contact = Contact(context: self.context)
            self.isNew = true
        }

        //새로운 context를 매번 만들어서 사용하지않기위해 self.context에 저장
    }

    func save() throws {
        try provider.persist(in: context)
    }
}
