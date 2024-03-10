//
//  TodoList_CoreDataTests.swift
//  TodoList_CoreDataTests
//
//  Created by yangsu.baek on 2024/03/10.
//

import XCTest
@testable import TodoList_CoreData

final class TodoList_CoreDataTests: XCTestCase {
    //safety check

    private var provider: ContactsProvider!

    override func setUp() async throws {
        provider = ContactsProvider.shared
    }

    override func tearDown() {
        provider = nil
    }

    func textContactIsEmpty() {
        let contact = Contact.empty(context: provider.viewContext)
        XCTAssertEqual(contact.name, "")
        XCTAssertEqual(contact.email, "")
        XCTAssertEqual(contact.phoneNumber, "")
        XCTAssertEqual(contact.notes, "")
        XCTAssertFalse(contact.isFavourite)
        XCTAssertTrue(Calendar.current.isDateInToday(contact.dob))

    }

    func testContatisNotValid() {
        let contact = Contact.empty(context: provider.viewContext)
        XCTAssertFalse(contact.isValid)
    }

    func testContatisValid() {
        let contact = Contact.preview(context: provider.viewContext)
        XCTAssertTrue(contact.isValid)
    }

    func testContactBirthdayIsValid() {
        //생성된 contact의 생일이 오늘이면 isBirthday = true, cotact만들면 젤 처음꺼는 생일이 오늘임
        let contact = Contact.preview(context: provider.viewContext)
        XCTAssertTrue(contact.isBirthday)
    }

    func testContactBirthdayIsNotValid() throws {
        //마지막에 생성된 contact는 생일이 오늘이 아님
        //XCTUnwrap nil일수도있는 값을 강제로 ! 타입으로 바꿔줌, nil아닌걸로
        let contact = try XCTUnwrap(Contact.makePreview(count: 2, in: provider.viewContext).last)
        XCTAssertFalse(contact.isBirthday)
    }

    func testMakeContactPreviewIsValid() {
        let count = 5
        let contacts = Contact.makePreview(count: count, in: provider.viewContext)

        for contact in contacts {
            XCTAssertTrue(contact.isValid)
        }

    }

    func testFilterFaveContactsRequestIsValid() {
        let request = Contact.filter(with: .init(filter: .fave))
        XCTAssertEqual(request.predicateFormat, "isFavourite == 1")
        //필터의 포멧이 제대로 설정됐는지 테스트
    }

    func testFilterAllContactsRequestIsValid() {
        let request = Contact.filter(with: .init(filter: .all))
        XCTAssertEqual(request.predicateFormat, "TRUEPREDICATE")
        //필터의 포멧이 제대로 설정됐는지 테스트
    }


    func testFilterAllWithQueryContactsRequestIsValid() {
        let query = "1"
        let request = Contact.filter(with: .init(query: "1"))
        XCTAssertEqual(request.predicateFormat, "name CONTAINS[cd] \"\(query)\"")

        //"name CONTAINS[cd] "1"" 형태임
    }
    

    func testFilterFaveWithQueryContactsRequestIsValid() {
        let query = "1"
        let request = Contact.filter(with: .init(query: "1", filter: .fave))
        XCTAssertEqual(request.predicateFormat, "name CONTAINS[cd] \"\(query)\" AND isFavourite == 1")
    }

}
