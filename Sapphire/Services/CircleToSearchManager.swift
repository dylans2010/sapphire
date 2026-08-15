import Foundation

extension Notification.Name {
    static let sapphireOpenCircleToSearch = Notification.Name("sapphireOpenCircleToSearch")
}

@MainActor
final class CircleToSearchManager: ObservableObject {
    static let shared = CircleToSearchManager()

    private init() {}

    func endResultsPresentation() {}
}
