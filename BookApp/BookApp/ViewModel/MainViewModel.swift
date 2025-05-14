import Foundation
import RxSwift

protocol MainViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Output
    
    func transform(with: Input) -> Output
}

class MainViewModel: MainViewModelProtocol {
    
    struct Input {
        
    }
    
    struct Output {
        
    }
    
    func transform(with: Input) -> Output {
        <#code#>
    }

}
