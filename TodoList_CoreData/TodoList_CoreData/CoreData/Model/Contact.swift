//
//  Contact.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import Foundation
import CoreData


final class Contact: NSManagedObject, Identifiable {
    @NSManaged var dob: Date
    @NSManaged var email: String
    @NSManaged var isFavourite: Bool
    @NSManaged var notes: String
    @NSManaged var name: String
    @NSManaged var phoneNumber: String

    var isValid: Bool {
        !name.isEmpty &&
        !phoneNumber.isEmpty &&
        !email.isEmpty
    }

    var isBirthday: Bool {
        Calendar.current.isDateInToday(dob)
    }

    var formattedName: String {
        "\(isBirthday ? "🎂" : "")\(name)"
    }

    override func awakeFromInsert() {
        super.awakeFromInsert()
        //invoked after an insert

        //nil을 대비해 디폴트값 저장
        setPrimitiveValue(Date.now, forKey: "dob")
        setPrimitiveValue(false, forKey: "isFavourite")
    }

    func toggleFave(provider: ContactsProvider) {
        //수정할때마다 세이브 해줘야함 그래야 업뎃 되고 새로 패치함
        isFavourite.toggle()
        do {
            try provider.persist(in: provider.newContext)
        } catch {
            print(error)
        }

    }
}


extension Contact {
    private static var contactsFetchRequest: NSFetchRequest<Contact> {
        NSFetchRequest(entityName: "Contact")
    }

    static func all() -> NSFetchRequest<Contact> {
        let request: NSFetchRequest<Contact> = contactsFetchRequest
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Contact.name, ascending: true)
        ]
        //이름으로 오름차순 정렬
        return request
    }

    static func filter(with config : SearchConfig) -> NSPredicate {

        switch config.filter {
        case .all:
            //필터룰 name에 query있는걸 필터링해주는 룰
            return config.query.isEmpty ? NSPredicate(value: true) : NSPredicate(format: "name CONTAINS[cd] %@" , config.query)
        case.fave:
            return config.query.isEmpty ?
            NSPredicate(format: "isFavourite == %@", NSNumber(value: true)) :
            NSPredicate(format: "name CONTAINS[cd] %@ AND isFavourite == %@" , config.query, NSNumber(value: true))
            //query가 없으면 fave 필터링결과만 보여주면됨
        }
    }

    static func sort(order: Sort) -> [NSSortDescriptor] {
        [NSSortDescriptor(keyPath: \Contact.name, ascending: order == .asc)]
    }
}


extension Contact  {
    //사용필요없으면 지워버리는 벨류
    @discardableResult
    static func makePreview(count: Int, in context: NSManagedObjectContext) -> [Contact] {
        var contacts = [Contact]()

        for i in 0..<count {
            let contact = Contact(context: context)
            contact.name = "item \(i)"
            contact.email = "item\(i)@email.com"
            contact.isFavourite = Bool.random()
            contact.phoneNumber = "00011100022\(i)"
            contact.dob = Calendar.current.date(byAdding: .day, value: -i, to: .now) ?? .now
            contact.notes = "This is preview item \(i)"

            contacts.append(contact)
        }

        return contacts
    }

    static func preview(context: NSManagedObjectContext = ContactsProvider.shared.viewContext) -> Contact {
        return makePreview(count: 1, in: context)[0]
    }

    static func empty(context: NSManagedObjectContext = ContactsProvider.shared.viewContext) -> Contact {
        return Contact(context: context)
    }
}
