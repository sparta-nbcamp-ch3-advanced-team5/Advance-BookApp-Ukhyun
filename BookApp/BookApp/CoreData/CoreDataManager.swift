//
//  CoreDataManager.swift
//  BookApp
//
//  Created by GO on 5/13/25.
//

import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookListEntity")
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Core Data 로드 실패: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = mainContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("CoreData 저장 실패: \(error), \(error.userInfo)")
            }
        }
    }
    // MARK: - CRUD - Create, Read만 구현
    func saveBook(title: String, author: String, price: String) -> BookListEntity? {
        let context = mainContext
        
        // 중복 처리
        if let existBook = fetchBook(title: title, author: author) {
            return existBook
        }
        
        let book = BookListEntity(context: context)
        book.title = title
        book.author = author
        book.price = price
        
        do {
            try context.save()
            return book
        } catch {
            print("책 저장 실패 : \(error)")
            context.rollback()
            return nil
        }
    }
    
    func fetchAllBooks() -> [BookListEntity] {
        let request: NSFetchRequest<BookListEntity> = BookListEntity.fetchRequest()
        
        do {
            return try mainContext.fetch(request)
        } catch {
            print("책 목록 조회 실패: \(error)")
            return []
        }
    }
    
    func fetchBook(title: String, author: String) -> BookListEntity? {
        let request: NSFetchRequest<BookListEntity> = BookListEntity.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@ AND author == %@", title, author)
        request.fetchLimit = 1
        
        do {
            let results = try mainContext.fetch(request)
            return results.first
        } catch {
            print("책 조회 실패: \(error)")
            return nil
        }
    }
    
    
}
