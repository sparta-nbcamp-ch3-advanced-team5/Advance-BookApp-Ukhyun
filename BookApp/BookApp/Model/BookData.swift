import Foundation

struct BookSearchResponse: Codable {
    let documents: [BookDocument]
}

struct BookDocument: Codable {
    let title: String
    let authors: [String]
    let contents: String
    let thumbnail: String?
    let price: Int
}
