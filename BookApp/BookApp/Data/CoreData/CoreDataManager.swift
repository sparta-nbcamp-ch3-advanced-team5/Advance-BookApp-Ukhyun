import Foundation
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "BookApp")
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
    
    // 저장 - Create
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
    
    // 모든 책 조회 - Read
    func fetchAllBooks() -> [BookListEntity] {
        let request: NSFetchRequest<BookListEntity> = BookListEntity.fetchRequest()
        
        do {
            return try mainContext.fetch(request)
        } catch {
            print("책 목록 조회 실패: \(error)")
            return []
        }
    }
    
    // 특정 책 조회 - Read
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
    
    //  TODO: - Delete 구현
    // 모든 책 삭제 - Delete All
    func deleteAllBooks() -> Bool {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BookListEntity.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try mainContext.execute(batchDeleteRequest)
            // 메인 컨텍스트 상태 동기화
            mainContext.reset()
            return true
        } catch {
            print("모든 책 삭제 실패: \(error)")
            return false
        }
    }

}
