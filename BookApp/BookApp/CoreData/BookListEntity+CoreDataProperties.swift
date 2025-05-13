//
//  BookListEntity+CoreDataProperties.swift
//  BookApp
//
//  Created by GO on 5/13/25.
//
//

import Foundation
import CoreData


extension BookListEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookListEntity> {
        return NSFetchRequest<BookListEntity>(entityName: "BookListEntity")
    }

    @NSManaged public var author: String?
    @NSManaged public var price: String?
    @NSManaged public var title: String?

}

extension BookListEntity : Identifiable {

}
