import Foundation

extension Int {
    var numberFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        guard let formatted = formatter.string(for: self) else {
            return String(self)
        }
        return formatted
    }
}
