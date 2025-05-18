import Foundation

struct BookSearchResponse: Codable {
    let documents: [BookDocument]
    let meta: Meta
}

struct BookDocument: Codable {
    let title: String
    let authors: [String]
    let contents: String
    let thumbnail: String?
    let price: Int
}

struct Meta: Codable {
    let total_count: Int
    let pageable_count: Int
    let is_end: Bool
}
