import Foundation
import Alamofire
import RxSwift

enum KakaoBookAPI {
    case search(query: String, page: Int = 1, size: Int = 10, sort: String = "accuracy")

    var baseURL: String { "https://dapi.kakao.com/v3/search/" }

    var endPoint: URL {
        let path: String
        switch self {
        case .search:
            path = "book"
        }
        return URL(string: baseURL + path)!
    }

    var method: HTTPMethod {
        switch self {
        case .search:
            return .get
        }
    }

    var parameters: Parameters {
        switch self {
        case .search(let query, let page, let size, let sort):
            return [
                "query": query,
                "page": page,
                "size": size,
                "sort": sort
            ]
        }
    }

    var headers: HTTPHeaders {
        return ["Authorization": "KakaoAK \(APIKey.Key)"]
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    func callRequest<T: Decodable>(api: KakaoBookAPI) -> Observable<T> {
        return Observable.create { observer in
            let request = AF.request(
                api.endPoint,
                method: api.method,
                parameters: api.parameters,
                headers: api.headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                    observer.onCompleted()
                case .failure(let error):
                    let statusCode = response.response?.statusCode ?? -1
                    let errorMessage = self.handleError(error: error, statusCode: statusCode)
                    observer.onError(errorMessage)
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }

    private func handleError(error: AFError, statusCode: Int) -> Error {
        switch statusCode {
        case 400: return NSError(domain: "Bad Request", code: 400)
        case 401: return NSError(domain: "Invalid Token", code: 401)
        case 404: return NSError(domain: "Not Found", code: 404)
        case 500...599: return NSError(domain: "Server Error", code: statusCode)
        default: return error
        }
    }
}
