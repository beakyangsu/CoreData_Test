//
//  ContactsProvider.swift
//  TodoList_CoreData
//
//  Created by yangsu.baek on 2024/03/10.
//

import Foundation
import CoreData
import SwiftUI

//final : 상속과 오버라이드 못하게
final class ContactsProvider {
    static let shared = ContactsProvider()

    var isRunningTests: Bool {
        return ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    private let persistentContainer: NSPersistentContainer
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    var newContext: NSManagedObjectContext {
        persistentContainer.newBackgroundContext()
    }

    private init() {
        //name: xcdatamodeld파일명
        persistentContainer = NSPersistentContainer(name: "ContactDataModel")

        //더미 저장소 설정 
        //프리뷰이거나 유닛테스트일경우
        if EnvironmentValues.isPreview || isRunningTests {
            persistentContainer.persistentStoreDescriptions.first?.url = .init(filePath: "/dev/null")
        }

        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                fatalError("Unable to load store with error : \(error)")
            }
        }
    }

    func exsists(_ contact: Contact, context: NSManagedObjectContext) -> Contact? {
        try? context.existingObject(with: contact.objectID) as? Contact
    }

    func delete(_ contact: Contact, context: NSManagedObjectContext) throws {
        if let exsisting = exsists(contact, context: context) {
            context.delete(exsisting)

            //삭제한 변화를 저장
            //백그라운드 타스크로 저장
            Task(priority: .background) {
                try await context.perform {
                    try context.save()
                }
            }
        }
    }

    func persist(in context: NSManagedObjectContext) throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

//프리뷰에서도 코어데이터 동작하게 해줌
extension EnvironmentValues {
    static var isPreview: Bool {
        return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

}




